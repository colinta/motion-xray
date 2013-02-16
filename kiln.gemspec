# -*- encoding: utf-8 -*-
require File.expand_path('../lib/kiln/version.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'kiln'
  gem.version       = Kiln::Version

  gem.authors = ['Colin T.A. Gray']
  gem.email   = ['colinta@gmail.com']
  gem.summary     = %{I'll tell you at #inspect 2013!}
  gem.description = <<-DESC
This is a secret project of colinta.  It'll be pretty cool, I promise.
DESC

  gem.homepage    = 'https://github.com/colinta/kiln'

  gem.files        = `git ls-files`.split($\)
  gem.test_files   = gem.files.grep(%r{^spec/})

  gem.require_paths = ['lib']

  gem.add_dependency 'sugarcube'
  gem.add_dependency 'geomotion'

  gem.add_development_dependency 'teacup'
  gem.add_development_dependency 'rspec'
end