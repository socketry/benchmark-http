# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

module DisableConsoleContext
	def around
		level = Console.logger.level
		Console.logger.off!
		
		begin
			super
		ensure
			Console.logger.level = level
		end
	end
end
