# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'catflap/version'

Gem::Specification.new do |spec|
  spec.name          = "catflap"
  spec.version       = Catflap::VERSION
  spec.authors       = ["niv"]
  spec.email         = ["n@e-ix.net"]
  spec.summary       = %q{Companion management helper to catflap Updater.}
  spec.description   = ""
  spec.homepage      = "https://github.com/niv/catflap"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "colorize", '0.7.3'
  spec.add_runtime_dependency "filesize", '0.0.3'

  spec.required_ruby_version = '>= 1.9.3'
end
