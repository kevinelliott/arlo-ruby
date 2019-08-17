# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'arlo/version'

Gem::Specification.new do |spec|
  spec.name          = "arlo"
  spec.version       = Arlo::VERSION
  spec.authors       = ["Kevin Elliott"]
  spec.email         = ["kevin@welikeinc.com"]

  spec.summary       = %q{Ruby library for interacting with the NetGear Arlo camera system}
  spec.description   = %q{A ruby gem that contains a library for interacting with the NetGear Arlo security camera system.}
  spec.homepage      = "https://github.com/kevinelliott/arlo"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'awesome_print'
  spec.add_dependency 'ld-eventsource'
  spec.add_dependency 'lhc'
  spec.add_dependency 'pry'
  spec.add_dependency 'terminal-table'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.0"
end
