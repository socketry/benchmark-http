# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

require_relative 'seconds'
require_relative 'statistics'
require_relative 'links_filter'

require 'async'
require 'async/http/client'
require 'async/http/endpoint'
require 'async/await'

require 'uri'
require 'console'

module Benchmark
	module HTTP
		class Spider
			include Async::Await
			
			def initialize(depth: nil, ignore: nil)
				@depth = depth
				@ignore = ignore
			end
			
			def extract_links(url, response)
				base = url
				
				body = response.read
				
				begin
					filter = LinksFilter.parse(body)
				rescue
					Console.logger.error(self) {$!}
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
						Console.logger.warn(self) {"Could not fetch #{href}, relative to #{base}!"}
						next # Don't accumulate an item into the resulting array.
					end
				end.compact
			end
			
			async def fetch(statistics, client, url, depth = @depth, fetched = Set.new, &block)
				if depth&.zero?
					Console.logger.warn(self) {"Exceeded depth while trying to visit #{url}!"}
					return
				elsif fetched.include?(url)
					return
				elsif @ignore&.match?(url.path)
					return
				end
				
				fetched << url
				
				request_uri = url.request_uri
				
				response = client.head(request_uri).tap(&:read)
				
				yield("HEAD", url, response) if block_given?
				
				if response.redirection?
					location = url + response.headers['location']
					if location.host == url.host
						Console.logger.debug(self) {"Following redirect to #{location}..."}
						fetch(statistics, client, location, depth&.-(1), fetched, &block).wait
						return
					else
						Console.logger.debug(self) {"Ignoring redirect to #{location}."}
						return
					end
				end
				
				content_type = response.headers['content-type']
				unless content_type&.start_with? 'text/html'
					# puts "Unsupported content type: #{content_type}"
					return
				end
				
				response = statistics.measure do
					client.get(request_uri)
				end
				
				yield("GET", url, response) if block_given?
				
				extract_links(url, response) do |href|
					fetch(statistics, client, href, depth&.-(1), fetched, &block)
				end.each(&:wait)
			rescue Async::TimeoutError => error
				Console.logger.error(self, error, url: url)
			rescue StandardError => error
				Console.logger.error(self, error)
			end
			
			sync def call(urls, &block)
				statistics = Statistics.new
				
				urls.each do |url|
					endpoint = Async::HTTP::Endpoint.parse(url, timeout: 10)
					
					Async::HTTP::Client.open(endpoint, protocol: endpoint.protocol, limit: 4) do |client|
						fetch(statistics, client, endpoint.url, &block).wait
					end
				end
				
				return statistics
			end
		end
	end
end
