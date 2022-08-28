# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2022, by Samuel Williams.

require 'benchmark/http/command'

RSpec.describe Benchmark::HTTP::Spider do
	let(:statistics) {subject.call(["https://www.codeotaku.com/"])}
	
	it "can spider some pages" do
		expect(statistics.count).to be > 0
	end
	
	context "ignore everything" do
		subject{described_class.new(ignore: //)}
		
		it "ignores all pages" do
			expect(statistics.count).to be_zero
		end
	end
end
