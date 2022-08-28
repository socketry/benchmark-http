# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

require_relative '../seconds'
require_relative '../statistics'

require 'async'
require 'async/http/client'
require 'async/http/endpoint'

require 'samovar'

module Benchmark
	module HTTP
		module Command
			class Hammer < Samovar::Command
				self.description = "Hammer a single URL and report statistics."
				
				options do
					option "-k/--concurrency <count>", "The number of simultaneous connections to make.", default: 1, type: Integer
					option '-c/--count <integer>', "The number of requests to make per connection.", default: 10_000, type: Integer
					
					option '-i/--interval <integer>', "The time to wait between measurements.", default: nil, type: Integer
					option '--alpn-protocols <name,name>', "Force specific ALPN protocols during connection negotiation.", default: nil, type: String
				end
				
				many :urls, "The urls to hammer."
				
				def measure_performance(concurrency, count, endpoint, request_path)
					Console.logger.info(self) {"I am running #{concurrency} asynchronous tasks that will each make #{count} sequential requests..."}
					
					statistics = Statistics.new(concurrency)
					task = Async::Task.current
					running = true
					
					progress_task = task.async do |child|
						while true
							child.sleep(1)
							Console.logger.info(self, statistics)
						end
					end
					
					concurrency.times.map do
						task.async do
							client = Async::HTTP::Client.new(endpoint, protocol: endpoint.protocol)
							
							count.times do |i|
								statistics.measure do
									response = client.get(request_path).tap(&:finish)
								end
							end
							
							client.close
						end
					end.each(&:wait)
					
					progress_task&.stop
					
					Console.logger.info(self) do |buffer|
						buffer.puts "I made #{statistics.count} requests in #{Seconds[statistics.sequential_duration]}. The per-request latency was #{Seconds[statistics.latency]}. That's #{statistics.per_second} asynchronous requests/second."
						buffer.puts "\t          Variance: #{Seconds[statistics.variance]}"
						buffer.puts "\tStandard Deviation: #{Seconds[statistics.standard_deviation]}"
						buffer.puts "\t    Standard Error: #{Seconds[statistics.standard_error]}"
						buffer.puts statistics
					end
					
					return statistics
				end
				
				def alpn_protocols
					@options[:alpn_protocols]&.split(',')
				end
				
				def run(url)
					endpoint = Async::HTTP::Endpoint.parse(url, alpn_protocols: self.alpn_protocols)
					request_path = endpoint.url.request_uri
					
					Console.logger.info(self) {"I am going to benchmark #{url}..."}
					
					Sync do |task|
						statistics = []
						
						base = measure_performance(@options[:concurrency], @options[:count], endpoint, request_path)
					end
				end
				
				def call
					while true
						@urls.each do |url|
							run(url)
						end
						
						if @interval
							sleep(@interval)
						else
							break
						end
					end
				end
			end
		end
	end
end
