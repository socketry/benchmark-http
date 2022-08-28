# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require 'disable_console_context'
require 'benchmark/http/command'

describe Benchmark::HTTP::Command::Spider do
	include DisableConsoleContext
	
	let(:command) {subject["--depth", 4, "https://www.codeotaku.com/"]}
	let(:statistics) {command.call}
	
	it "can spider some pages" do
		expect(statistics.count).to be > 0
	end
end
