# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

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
