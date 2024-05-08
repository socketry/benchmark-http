# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2024, by Samuel Williams.

require 'xrb/sanitize'

module Benchmark
	module HTTP
		class LinksFilter < XRB::Sanitize::Filter
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
				elsif node.name == 'a' and node['href'] and node['rel'] != 'nofollow'
					@links << node['href']
				end
				
				node.skip!(TAG)
			end
		end
	end
end
