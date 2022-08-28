# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require_relative 'command/latency'
require_relative 'command/concurrency'
require_relative 'command/spider'
require_relative 'command/hammer'
require_relative 'command/wait'

require_relative 'version'
require 'samovar'
require 'console'

module Benchmark
	module HTTP
		module Command
			def self.call(*args)
				Top.call(*args)
			end
			
			class Top < Samovar::Command
				self.description = "An asynchronous HTTP server benchmark."
				
				options do
					option '--verbose | --quiet', "Verbosity of output for debugging.", key: :logging
					option '-h/--help', "Print out help information."
					option '-v/--version', "Print out the application version."
				end
				
				nested :command, {
					'latency' => Latency,
					'concurrency' => Concurrency,
					'spider' => Spider,
					'hammer' => Hammer,
					'wait' => Wait,
				}
				
				def verbose?
					@options[:logging] == :verbose
				end
				
				def quiet?
					@options[:logging] == :quiet
				end
				
				def call
					if verbose?
						Console.logger.debug!
					elsif quiet?
						Console.logger.warn!
					end
					
					if @options[:version]
						puts "#{self.name} v#{VERSION}"
					elsif @options[:help]
						self.print_usage
					else
						@command.call
					end
				end
			end
		end
	end
end
