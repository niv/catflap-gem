# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'catflap/version'

Gem::Specification.new do |spec|
  spec.name          = "catflap"
  spec.version       = Catflap::VERSION
  spec.authors       = ["niv"]
  spec.email         = ["n@e-ix.net"]
  spec.summary       = %q{Companion management helper to Catflap Updater UI.}
  spec.description   = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "colorize", '0.7.3'
  spec.add_runtime_dependency "filesize", '0.0.3'
  spec.add_runtime_dependency "ruby-terminfo", '0.1.1'
end
