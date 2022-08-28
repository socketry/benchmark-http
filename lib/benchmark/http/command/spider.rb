# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require_relative '../spider'

require 'async/await'

require 'samovar'
require 'uri'
require 'console'

module Benchmark
	module HTTP
		module Command
			class Spider < Samovar::Command
				include Async::Await
				
				self.description = "Spider a website and report on performance."
				
				options do
					option '-d/--depth <count>', "The number of nested URLs to traverse.", default: 10, type: Integer
					option '-h/--headers', "Print out the response headers", default: false
				end
				
				many :urls, "One or more hosts to benchmark"
				
				def log(method, url, response)
					Console.logger.call(self, severity: (response.failure? ? :warn : :info)) do |buffer|
						buffer.puts "#{method} #{url} -> #{response.version} #{response.status} (#{response.body&.length || 'unspecified'} bytes)"
						
						response.headers.each do |key, value|
							buffer.puts "\t#{key}: #{value}"
						end if @options[:headers]
					end
				end
				
				sync def call
					spider = HTTP::Spider.new(depth: @options[:depth])
					
					statistics = spider.call(@urls, &self.method(:log))
					
					statistics.print
					
					return statistics
				end
			end
		end
	end
end
