# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

require 'trenni/sanitize'

module Benchmark
	module HTTP
		class LinksFilter < Trenni::Sanitize::Filter
			def initialize(*)
				super
				
				@base = nil
				@links = []
			end
			
			attr :base
			attr :links
			
			def filter(node)
				if node.name == 'base'
					@base = node['href']
				elsif node.name == 'a'
					@links << node['href']
				end
				
				node.skip!(TAG)
			end
		end
	end
end
