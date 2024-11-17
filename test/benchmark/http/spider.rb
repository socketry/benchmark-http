# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020-2024, by Samuel Williams.

require "benchmark/http/command"

require "sus/fixtures/console/null_logger"

describe Benchmark::HTTP::Spider do
	include Sus::Fixtures::Console::NullLogger
	
	let(:spider) {subject.new}
	let(:statistics) {spider.call(["https://www.codeotaku.com/"])}
	
	it "can spider some pages" do
		expect(statistics.count).to be > 0
	end
	
	with "ignore everything option" do
		let(:spider) {subject.new(ignore: //)}
		
		it "ignores all pages" do
			expect(statistics.count).to be == 0
		end
	end
end
