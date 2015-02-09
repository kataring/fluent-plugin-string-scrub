# coding: utf-8
lib = File.expand_path('../lib', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-string-scrub"
  spec.version       = "0.0.3"
  spec.authors       = ["Noriaki Katayama"]
  spec.email         = ["kataring@gmail.com"]
  spec.summary       = %q{Fluentd Output filter plugin.}
  spec.description   = %q{fluent plugin for string scrub.}
  spec.homepage      = "https://github.com/kataring/fluent-plugin-string-scrub"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "fluentd"
  spec.add_runtime_dependency "string-scrub", "~> 0.0.5" if RUBY_VERSION.to_f < 2.1
end
