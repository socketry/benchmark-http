# frozen_string_literal: true

require_relative "lib/benchmark/http/version"

Gem::Specification.new do |spec|
	spec.name = "benchmark-http"
	spec.version = Benchmark::HTTP::VERSION
	
	spec.summary = "An asynchronous benchmark toolbox for modern HTTP servers."
	spec.authors = ["Samuel Williams", "Olle Jonsson"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/benchmark-http"
	
	spec.files = Dir.glob(['{bin,lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.executables = ["benchmark-http"]
	
	spec.required_ruby_version = ">= 2.4"
	
	spec.add_dependency "async-await"
	spec.add_dependency "async-http", "~> 0.54"
	spec.add_dependency "async-io", "~> 1.5"
	spec.add_dependency "console"
	spec.add_dependency "samovar", "~> 2.0"
	spec.add_dependency "trenni-sanitize"
	
	spec.add_development_dependency "async-rspec"
	spec.add_development_dependency "bake-test"
	spec.add_development_dependency "bake-test-external"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "sus", "~> 0.12"
end
