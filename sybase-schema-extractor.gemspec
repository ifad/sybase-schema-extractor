# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sybase/schema/extractor/version'

Gem::Specification.new do |spec|
  spec.name          = "sybase-schema-extractor"
  spec.version       = Sybase::Schema::Extractor::VERSION
  spec.authors       = ["Mark Burns"]
  spec.email         = ["markthedeveloper@gmail.com"]
  spec.summary       = %q{Use active record to extract a schema.rb from a sybase database}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord-sybase-adapter"
  spec.add_dependency "activerecord", "~> 4.1.8"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
