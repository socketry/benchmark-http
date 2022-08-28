# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

module Benchmark
	module HTTP
		class Seconds
			UNITS = ["s", "ms", "µs"]
			SCALE = UNITS.size - 1
			
			def self.[](value)
				self.new(value)
			end
			
			def initialize(value)
				@value = value
			end
			
			def scale
				Math.log(@value) / Math.log(1000)
			end
			
			def to_s
				scaled_value = @value
				scale = 0
				
				while scaled_value < 1 && scale < SCALE
					scaled_value *= 1000
					scale += 1
				end
				
				return sprintf("%0.#{scale+1}f%s", scaled_value, UNITS.fetch(scale))
			end
		end
	end
end
