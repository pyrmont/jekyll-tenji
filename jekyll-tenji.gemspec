# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tenji/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyll-tenji"
  spec.version       = Tenji::VERSION
  spec.authors       = ["Michael Camilleri"]
  spec.email         = ["dev@inqk.net"]

  spec.summary       = %q{A Jekyll plugin for creating photo galleries.}
  spec.description   = %q{Tenji creates sophisticated photo galleries with minimal effort.}
  spec.homepage      = "https://github.com/pyrmont/jekyll-tenji/"
  spec.license       = "Unlicense"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.5.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.requirements << "imagemagick, >=v6.9 (RMagick dependency)"

  spec.add_runtime_dependency "rmagick", "~> 2.16.0"
  spec.add_runtime_dependency "exifr", "~> 1.3.0"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "jekyll", "~> 3.8.3"
  spec.add_development_dependency "minitest", "~> 5.10.3"
  spec.add_development_dependency "minitest-reporters", "~> 1.1.19"
  spec.add_development_dependency "shoulda-context", "~> 1.2.0"
  spec.add_development_dependency "simplecov", "~> 0.15.1"
  spec.add_development_dependency "yard", "~> 0.9.12"
end
