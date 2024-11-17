# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require "async/clock"

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
				@samples.size > 0
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
			
			def to_s
				if self.valid?
					"#{@samples.size} samples. #{per_second} requests per second. S/D: #{Seconds[standard_deviation]}."
				else
					"Not enough samples."
				end
			end
			
			def to_json(options)
				{
					count: self.count,
					concurrency: self.concurrency,
					latency: self.latency,
					standard_deviation: self.standard_deviation,
					standard_error: self.standard_error,
					per_second: self.per_second,
					duration: self.duration,
					variance: self.variance,
				}.to_json(options)
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
			
			attr :responses
			
			def failed
				@responses.sum{|status, count| status >= 400 ? count : 0}
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
