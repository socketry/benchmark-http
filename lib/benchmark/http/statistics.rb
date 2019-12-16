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

require 'async/clock'

module Benchmark
	module HTTP
		class Stopwatch
			def initialize(concurrency = 0)
				@samples = []
				
				# The number of currently executing measurements:
				@count = 0
				
				@concurrency = concurrency
				@start_time = nil
			end
			
			# The individual samples' durations.
			attr :samples
			
			# The maximum number of executing measurements at any one time.
			attr :concurrency
			
			def duration
				@samples.sum
			end
			
			def sequential_duration
				duration / @concurrency
			end
			
			def count
				@samples.size
			end
			
			def per_second(duration = self.sequential_duration)
				@samples.size.to_f / duration.to_f
			end
			
			def latency
				duration.to_f / count.to_f
			end
			
			def similar?(other, difference = 2.0)
				ratio = other.latency / self.latency
				
				return ratio < difference
			end
			
			def average
				if @samples.any?
					@samples.sum / @samples.size
				end
			end
			
			def valid?
				@samples.size > 1
			end
			
			# Computes Population Variance, σ^2.
			def variance
				if valid?
					average = self.average
					
					return @samples.map{|n| (n - average)**2}.sum / @samples.size
				end
			end
			
			# Population Standard Deviation, σ
			def standard_deviation
				if variance = self.variance
					Math.sqrt(variance.abs)
				end
			end
			
			def standard_error
				if standard_deviation = self.standard_deviation
					standard_deviation / Math.sqrt(@samples.size)
				end
			end
			
			def add(duration, result = nil)
				@samples << duration
			end
			
			def measure
				@count += 1
				
				if @count > @concurrency
					@concurrency = @count
				end
				
				start_time = Async::Clock.now
				
				unless @start_time
					@start_time = start_time
				end
				
				result = yield
				
				end_time = Async::Clock.now
				
				self.add(end_time - start_time, result)
				
				return result
			ensure
				@count -= 1
			end
			
			def sample(confidence_factor, &block)
				yield
				
				begin
					measure(&block)
				end until confident?(confidence_factor)
			end
			
			def print(out = STDOUT)
				if self.valid?
					out.puts "#{@samples.size} samples. #{per_second} requests per second. S/D: #{Seconds[standard_deviation]}."
				else
					out.puts "Not enough samples."
				end
			end
			
			private
			
			def confident?(factor)
				if @samples.size > @concurrency * 10
					return self.standard_error < (self.average * factor)
				end
				
				return false
			end
		end
		
		class Statistics < Stopwatch
			def initialize(*)
				super
				
				# The count of the status codes seen in the responses:
				@responses = Hash.new{|h,k| 0}
			end
			
			def add(duration, result)
				super
				
				@responses[result.status] += 1
			end
			
			def print(out = STDOUT)
				if valid?
					counts = @responses.sort.collect{|status, count| "#{count}x #{status}"}.join("; ")
					
					out.puts "#{@samples.size} samples: #{counts}. #{per_second.round(2)} requests per second. S/D: #{Seconds[standard_deviation]}."
				else
					out.puts "Not enough samples."
				end
			end
		end
	end
end
