# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wheretocard/version'

Gem::Specification.new do |spec|
  spec.name          = "wheretocard"
  spec.version       = Wheretocard::VERSION
  spec.authors       = ["Henk Meijer"]
  spec.email         = ["henk.meijer@eskesmedia.nl"]

  spec.summary       = %q{Ruby binder to the Wherto CARD API}
  spec.description   = %q{Ruby binder to the Wherto CARD API}
  spec.homepage      = "http://www.eskesmedia.nl/"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "fakeweb"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "simplecov"


  # spec.add_dependency 'veto'
  # spec.add_dependency 'rubyntlm' #, '0.4.0'
  spec.add_dependency 'httparty'
  spec.add_dependency 'nokogiri'
  # spec.add_dependency 'railties'

end