# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require "benchmark/http/command"

require "sus/fixtures/console/null_logger"

describe Benchmark::HTTP::Command::Spider do
	include Sus::Fixtures::Console::NullLogger
	
	let(:command) {subject["--depth", 4, "https://www.codeotaku.com/"]}
	let(:statistics) {command.call}
	
	it "can spider some pages" do
		expect(statistics.count).to be > 0
	end
end
