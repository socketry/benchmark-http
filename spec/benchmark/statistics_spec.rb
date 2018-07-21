
require 'benchmark/http/statistics'

RSpec.describe Benchmark::HTTP::Stopwatch do
	context "some samples" do
		let(:samples) {[2, 4, 4, 4, 5, 5, 7, 9]}
		
		before(:each) do
			samples.each do |value|
				subject.add(value)
			end
		end
		
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
