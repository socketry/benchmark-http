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

require_relative '../spider'

require 'async/await'

require 'samovar'
require 'uri'

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
					Async.logger.call(self, severity: (response.failure? ? :warn : :info)) do |buffer|
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
