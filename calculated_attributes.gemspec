# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'calculated_attributes/version'

Gem::Specification.new do |spec|
  spec.name          = 'calculated_attributes'
  spec.version       = CalculatedAttributes::VERSION
  spec.authors       = ['Zach Schneider']
  spec.email         = ['zach@aha.io']
  spec.summary       = 'Automatically add calculated attributes to ActiveRecord models.'
  spec.homepage      = 'https://github.com/aha-app/calculated_attributes'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'appraisal', '~> 1.0.3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'rubocop', '~> 0.49.0'
  spec.add_development_dependency 'sqlite3', '~> 1.3.10'

  spec.add_dependency 'activerecord', '>= 3.2.20'
end
