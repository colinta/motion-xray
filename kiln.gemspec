# -*- encoding: utf-8 -*-
require File.expand_path('../lib/kiln/version.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'kiln'
  gem.version       = Kiln::Version

  gem.authors = ['Colin T.A. Gray']
  gem.email   = ['colinta@gmail.com']
  gem.summary     = %{An in-app UI editing system for iOS}
  gem.description = <<-DESC
The simulator and RubyMotion REPL make on-device testing a painful cycle of
code, compile, check, repeat.  *Especially* when it comes to testing the UI,
where inexplicable differences can crop up between a device and the simulator.

Kiln is an in-app developer's toolbox.  Activate Kiln (usually by shaking the
phone) and a UI editor appears where you can add, modify, and remove views.

Why stop there!  There's a log panel, and an accessibility panel that gives you
a visiualization of how you app "looks" to the blind or color blind.

And you're damn right it's extensible!  You can write new UI editors, register
custom views, and add new panels, for instance maybe you need a Bluetooth device
scanner, or a way to check API requests.

Enjoy!
DESC

  gem.homepage    = 'https://github.com/colinta/kiln'

  gem.files        = `git ls-files`.split($\)
  gem.test_files   = gem.files.grep(%r{^spec/})

  gem.require_paths = ['lib']

  gem.add_dependency 'sugarcube', '>= 0.20.1'
  gem.add_dependency 'geomotion', '>= 0.7.0'

  gem.add_development_dependency 'rspec'
end
