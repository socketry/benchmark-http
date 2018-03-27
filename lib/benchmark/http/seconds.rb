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

module Benchmark
	module HTTP
		class Seconds
			UNITS = ["s", "ms", "µs"]
			SCALE = UNITS.count - 1
			
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
