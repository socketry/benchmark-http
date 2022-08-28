# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require 'benchmark/http/statistics'

RSpec.describe Benchmark::HTTP::Stopwatch do
	context "with no samples" do
		it {is_expected.to_not be_valid}
		
		it "should have no average" do
			expect(subject.average).to be_nil
		end
	end
	
	context "with some samples" do
		let(:samples) {[2, 4, 4, 4, 5, 5, 7, 9]}
		
		before(:each) do
			samples.each do |value|
				subject.add(value)
			end
		end
		
		it {is_expected.to be_valid}
		
		it "has correct sample count" do
			expect(subject.count).to be == 8
		end
		
		it "computes average" do
			expect(subject.average).to be == 5.0
		end
		
		it "computes variance" do
			expect(subject.variance).to be == 4.0
		end
		
		it "computes population standard deviation" do
			expect(subject.standard_deviation).to be == 2.0
		end
	end
end
