# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require "benchmark/http/statistics"

describe Benchmark::HTTP::Stopwatch do
	let(:stopwatch) {subject.new}
	
	with "no samples" do
		it "should have no average" do
			expect(stopwatch).to have_attributes(
				valid?: be == false,
				count: be == 0,
				average: be_nil,
			)
		end
	end
	
	with "some samples" do
		let(:samples) {[2, 4, 4, 4, 5, 5, 7, 9]}
		
		it "is valid and has computed an aggregate" do
			samples.each do |value|
				stopwatch.add(value)
			end
			
			expect(stopwatch).to have_attributes(
				valid?: be == true,
				count: be == 8,
				average: be == 5.0,
				variance: be == 4.0,
				standard_deviation: be == 2.0
			)
		end
	end
end
