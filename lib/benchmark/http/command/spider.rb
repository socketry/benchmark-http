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
require_relative '../links_filter'

require 'async'
require 'async/http/client'
require 'async/http/endpoint'
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
					puts "#{method} #{url} -> #{response.version} #{response.status} (#{response.body&.length || 'unspecified'} bytes)"
					
					response.headers.each do |key, value|
						puts "\t#{key}: #{value}"
					end if @options[:headers]
				end
				
				def extract_links(url, response)
					base = url
					
					body = response.read
					
					begin
						filter = LinksFilter.parse(body)
					rescue
						Async.logger.error($!)
						return []
					end
					
					if filter.base
						base = base + filter.base
					end
					
					filter.links.collect do |href|
						next if href.nil? or href.empty?
						
						begin
							full_url = base + href
							
							if full_url.host == url.host && full_url.kind_of?(URI::HTTP)
								yield full_url
							end
						rescue ArgumentError, URI::InvalidURIError
							puts "Could not fetch #{href}, relative to #{base}."
						end
					end.compact
				end
				
				async def fetch(statistics, client, url, depth = @options[:depth], fetched = Set.new)
					return if fetched.include?(url) or depth == 0
					
					fetched << url
					
					request_uri = url.request_uri
					
					response = client.head(request_uri).tap(&:read)
					
					log("HEAD", url, response)
					
					if response.redirection?
						location = url + response.headers['location']
						if location.host == url.host
							puts "Following redirect to #{location}..."
							return fetch(statistics, client, location, depth-1, fetched).wait
						else
							puts "Ignoring redirect to #{location}."
							return
						end
					end
					
					content_type = response.headers['content-type']
					unless content_type&.start_with? 'text/html'
						puts "Unsupported content type: #{content_type}"
						return
					end
					
					response = statistics.measure do
						client.get(request_uri)
					end
					
					log("GET", url, response)
					
					extract_links(url, response) do |href|
						fetch(statistics, client, href, depth - 1, fetched)
					end.each(&:wait)
				rescue Async::TimeoutError
					Async.logger.error("Timeout while fetching #{url}")
				rescue StandardError
					Async.logger.error($!)
				end
				
				async def call
					statistics = Statistics.new
					
					@urls.each do |url|
						endpoint = Async::HTTP::Endpoint.parse(url, timeout: 10)
						
						Async::HTTP::Client.open(endpoint, endpoint.protocol, connection_limit: 4) do |client|
							fetch(statistics, client, endpoint.url).wait
						end
					end
					
					statistics.print
					
					return statistics
				end
			end
		end
	end
end
