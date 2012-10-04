# -*- encoding: utf-8 -*-
require File.expand_path('../lib/paperclip/swift/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["MoD"]
  gem.email         = ["lbellet@heliostech.fr"]
  gem.description   = %q{Extends Paperclip with swift storage.}
  gem.summary       = %q{Paperclip openstack swift storage}
  gem.homepage      = "http://www.heliostech.fr"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "paperclip-swift"
  gem.require_paths = ["lib"]
  gem.version       = Paperclip::Swift::VERSION

  gem.add_dependency 'paperclip'
  gem.add_dependency 'openstack'
end
