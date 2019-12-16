# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative '../seconds'
require_relative '../statistics'

require 'async'
require 'async/http/client'
require 'async/http/endpoint'

require 'samovar'

module Benchmark
	module HTTP
		module Command
			class Latency < Samovar::Command
				self.description = "Determine the optimal level of concurrency."
				
				options do
					option "-k/--concurrency <count>", "The number of simultaneous connections to make.", default: 1, type: Integer
					option '-c/--confidence <factor>', "The confidence required when computing latency (lower is less reliable but faster)", default: 0.99, type: Float
				end
				
				many :hosts, "One or more hosts to benchmark"
				
				def confidence_factor
					1.0 - @options[:confidence]
				end
				
				def measure_performance(concurrency, endpoint, request_path)
					puts "I am running #{concurrency} asynchronous tasks that will each make sequential requests..."
					
					statistics = Statistics.new(concurrency)
					task = Async::Task.current
					
					concurrency.times.map do
						task.async do
							client = Async::HTTP::Client.new(endpoint, endpoint.protocol)
							
							statistics.sample(confidence_factor) do
								response = client.get(request_path).tap(&:finish)
							end
							
							client.close
						end
					end.each(&:wait)
					
					puts "I made #{statistics.count} requests in #{Seconds[statistics.sequential_duration]}. The per-request latency was #{Seconds[statistics.latency]}. That's #{statistics.per_second} asynchronous requests/second."
					puts "\t          Variance: #{Seconds[statistics.variance]}"
					puts "\tStandard Deviation: #{Seconds[statistics.standard_deviation]}"
					puts "\t    Standard Error: #{Seconds[statistics.standard_error]}"
					
					return statistics
				end
				
				def run(url)
					endpoint = Async::HTTP::Endpoint.parse(url)
					request_path = endpoint.url.request_uri
					
					puts "I am going to benchmark #{url}..."
					
					Async::Reactor.run do |task|
						statistics = []
						
						base = measure_performance(@options[:concurrency], endpoint, request_path)
					end
				end
				
				def call
					@hosts.each do |host|
						run(host).wait
					end
				end
			end
		end
	end
end
