# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_messenger/version'

Gem::Specification.new do |spec|
  spec.name          = "acts_as_messenger"
  spec.version       = ActsAsMessenger::VERSION
  spec.authors       = ["Kainage"]
  spec.email         = ["kainage@gmail.com"]
  spec.description   = %q{ Add basic messaging functionality between ActiveRecord models}
  spec.summary       = %q{Add basic messaging functionality between ActiveRecord models}
  spec.homepage      = "https://github.com/kainage/acts_as_messenger"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", "~> 4.0.0.rc1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "shoulda-matchers"
end
