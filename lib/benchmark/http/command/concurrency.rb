# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require_relative "../seconds"
require_relative "../statistics"

require "async"
require "async/http/client"
require "async/http/endpoint"

require "samovar"

module Benchmark
	module HTTP
		module Command
			class Concurrency < Samovar::Command
				self.description = "Determine the optimal level of concurrency."
				
				options do
					option "-t/--threshold <factor>", "The acceptable latency penalty when making concurrent requests", default: 1.2, type: Float
					option "-c/--confidence <factor>", "The confidence required when computing latency (lower is less reliable but faster)", default: 0.99, type: Float
					option "-m/--minimum <count>", "The minimum number of connections to make", default: 1, type: Integer
				end
				
				many :hosts, "One or more hosts to benchmark"
				
				def confidence_factor
					1.0 - @options[:confidence]
				end
				
				def measure_performance(concurrency, endpoint, request_path)
					Console.logger.info(self, url: endpoint.url) {"I am running #{concurrency} asynchronous tasks that will each make sequential requests..."}
					
					statistics = Statistics.new(concurrency)
					task = Async::Task.current
					
					concurrency.times.map do
						task.async do
							client = Async::HTTP::Client.new(endpoint, protocol: endpoint.protocol)
							
							statistics.sample(confidence_factor) do
								response = client.get(request_path).tap(&:finish)
							end
							
							client.close
						end
					end.each(&:wait)
					
					Console.logger.info(self, url: endpoint.url, concurrency: concurrency, statistics: statistics) do |buffer|
						buffer.puts "I made #{statistics.count} requests in #{Seconds[statistics.sequential_duration]}. The per-request latency was #{Seconds[statistics.latency]}. That's #{statistics.per_second.round(2)} asynchronous requests/second."
					
						buffer.puts "\t          Variance: #{Seconds[statistics.variance]}"
						buffer.puts "\tStandard Deviation: #{Seconds[statistics.standard_deviation]}"
						buffer.puts "\t    Standard Error: #{statistics.standard_error}"
					end
					
					return statistics
				end
				
				def run(url)
					endpoint = Async::HTTP::Endpoint.parse(url)
					request_path = endpoint.url.request_uri
					
					Console.logger.info(self) {"I am going to benchmark #{url}..."}
					
					Sync do |task|
						statistics = []
						minimum = @options[:minimum]
						
						base = measure_performance(minimum, endpoint, request_path)
						statistics << base
						
						current = minimum * 2
						maximum = nil
						
						while statistics.last.concurrency < current
							results = measure_performance(current, endpoint, request_path)
							
							if base.similar?(results, @options[:threshold])
								statistics << results
								
								minimum = current
								
								if maximum
									current += (maximum - current) / 2
								else
									current *= 2
								end
							else
								# current concurrency is too big, so we limit maximum to it.
								maximum = current
								
								current = (minimum + (maximum - minimum) / 2).floor
							end
						end
						
						Console.logger.info(self) do |buffer|
							buffer.puts "Your server can handle #{statistics.last.concurrency} concurrent requests."
							buffer.puts "At this level of concurrency, requests have ~#{(statistics.last.latency / statistics.first.latency).round(2)}x higher latency."
						end
					end
				end
				
				def call
					@hosts.each do |host|
						run(host)
					end
				end
			end
		end
	end
end
