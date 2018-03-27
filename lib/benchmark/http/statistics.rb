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
		class Statistics
			def initialize(concurrency = 1)
				@samples = []
				@duration = 0
				
				@concurrency = concurrency
			end
			
			attr :samples
			attr :duration
			
			attr :concurrency
			
			def sequential_duration
				@duration / @concurrency
			end
			
			def count
				@samples.count
			end
			
			def per_second
				@samples.count.to_f / sequential_duration.to_f
			end
			
			def latency
				@duration.to_f / @samples.count.to_f
			end
			
			def similar?(other, difference = 2.0)
				ratio = other.latency / self.latency
				
				return ratio < difference
			end
			
			def average
				if @samples.any?
					@samples.sum / @samples.count
				end
			end
			
			# Computes Population Variance, σ^2.
			def variance
				return nil if @samples.count < 2
				
				average = self.average
				
				return @samples.map{|n| (n - average)**2}.sum / @samples.count
			end
			
			# Population Standard Deviation, σ
			def standard_deviation
				if variance = self.variance
					Math.sqrt(variance.abs)
				end
			end
			
			def standard_error
				if standard_deviation = self.standard_deviation
					standard_deviation / Math.sqrt(@samples.count)
				end
			end
			
			def measure
				start_time = Time.now
				
				result = yield
				
				duration = Time.now - start_time
				@samples << duration
				@duration += duration
				
				return result
			end
			
			def sample(confidence_factor, &block)
				# warmup
				yield
				
				begin
					measure(&block)
				end until confident?(confidence_factor)
			end
			
			def print(out = STDOUT)
				if @samples.any?
					out.puts "#{@samples.count} samples. #{1.0 / self.average} per second. S/D: #{standard_deviation}."
				end
			end
			
			private
			
			def confident?(factor)
				(@samples.count > @concurrency) && self.standard_error < (self.average * factor)
			end
		end
	end
end
