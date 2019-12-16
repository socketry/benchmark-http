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
			class Concurrency < Samovar::Command
				self.description = "Determine the optimal level of concurrency."
				
				options do
					option '-t/--threshold <factor>', "The acceptable latency penalty when making concurrent requests", default: 1.2, type: Float
					option '-c/--confidence <factor>', "The confidence required when computing latency (lower is less reliable but faster)", default: 0.99, type: Float
					option '-m/--minimum <count>', "The minimum number of connections to make", default: 1, type: Integer
				end
				
				many :hosts, "One or more hosts to benchmark"
				
				def confidence_factor
					1.0 - @options[:confidence]
				end
				
				def measure_performance(concurrency, endpoint, request_path)
					puts
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
					
					puts "I made #{statistics.count} requests in #{Seconds[statistics.sequential_duration]}. The per-request latency was #{Seconds[statistics.latency]}. That's #{statistics.per_second.round(2)} asynchronous requests/second."
					
					puts "\t          Variance: #{Seconds[statistics.variance]}"
					puts "\tStandard Deviation: #{Seconds[statistics.standard_deviation]}"
					puts "\t    Standard Error: #{statistics.standard_error}"
					
					return statistics
				end
				
				def run(url)
					endpoint = Async::HTTP::Endpoint.parse(url)
					request_path = endpoint.url.request_uri
					
					puts "I am going to benchmark #{url}..."
					
					Async::Reactor.run do |task|
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
						
						puts "Your server can handle #{statistics.last.concurrency} concurrent requests."
						
						puts "At this level of concurrency, requests have ~#{(statistics.last.latency / statistics.first.latency).round(2)}x higher latency."
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
