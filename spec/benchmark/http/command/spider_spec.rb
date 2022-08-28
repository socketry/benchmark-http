# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require 'benchmark/http/command'

RSpec.describe Benchmark::HTTP::Command::Spider do
	let(:parent) {Benchmark::HTTP::Command::Top[]}
	subject {described_class["--depth", 4, "https://www.codeotaku.com/"]}
	
	let(:statistics) {subject.call}
	
	it "can spider some pages" do
		expect(statistics.count).to be > 0
	end
end
