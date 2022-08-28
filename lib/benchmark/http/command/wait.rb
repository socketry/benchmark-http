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
require 'async/barrier'
require 'async/http/client'
require 'async/http/endpoint'

require 'samovar'

module Benchmark
	module HTTP
		module Command
			class Wait < Samovar::Command
				self.description = "Measure how long it takes for an endpoint to become accessible."
				
				options do
					option '-w/--wait <time>', "The maximum wait time.", default: 10, type: Float
				end
				
				many :hosts, "The hosts to wait for."
				
				def run(url, parent: Async::Task.current)
					endpoint = Async::HTTP::Endpoint.parse(url)
					request_path = endpoint.url.request_uri
					maximum_wait = @options[:wait]
					
					parent.async do
						clock = Async::Clock.start
						
						client = Async::HTTP::Client.new(endpoint)
						
						begin
							client.get(request_path).tap(&:finish)
						rescue => error
							if clock.total > maximum_wait
								raise
							else
								sleep 0.01
								retry
							end
						end
						
						puts "#{url} is ready after #{clock.total} seconds."
					ensure
						client.close
					end
				end
				
				def call
					Sync do |task|
						barrier = Async::Barrier.new
						
						@hosts.each do |host|
							run(host, parent: barrier)
						end
						
						barrier.wait
					end
				end
			end
		end
	end
end
