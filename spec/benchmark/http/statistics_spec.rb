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

require 'benchmark/http/statistics'

RSpec.describe Benchmark::HTTP::Stopwatch do
	context "no samples" do
		it "should have no average" do
			expect(subject.average).to be_nil
		end
	end
	
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
