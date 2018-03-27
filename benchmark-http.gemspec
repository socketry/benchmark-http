require_relative "lib/benchmark/http/version"

Gem::Specification.new do |spec|
	spec.name          = "benchmark-http"
	spec.version       = Benchmark::HTTP::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]

	spec.summary       = %q{TODO: Write a short summary, because RubyGems requires one.}
	spec.description   = %q{TODO: Write a longer description or delete this line.}
	spec.homepage      = "TODO: Put your gem's website or public repo URL here."

	spec.files         = `git ls-files -z`.split("\x0").reject do |f|
		f.match(%r{^(test|spec|features)/})
	end

	spec.bindir        = "bin"
	spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
	spec.require_paths = ["lib"]

	spec.add_dependency "samovar"

	spec.add_development_dependency "bundler", "~> 1.16"
	spec.add_development_dependency "rake", "~> 10.0"
	spec.add_development_dependency "rspec", "~> 3.0"
end
