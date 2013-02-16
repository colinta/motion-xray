# -*- encoding: utf-8 -*-
require File.expand_path('../lib/kiln/version.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'kiln'
  gem.version       = Kiln::Version

  gem.authors = ['Colin T.A. Gray']
  gem.email   = ['colinta@gmail.com']
  gem.summary     = %{An in-app UI editing system for iOS, with teacup code generation}
  gem.description = <<-DESC
The simulator and RubyMotion REPL make on-device testing a painful cycle of
code, compile, check, repeat.  *Especially* when it comes to testing the UI,
where inexplicable differences can crop up between a device and the simulator.

Kiln is an in-app developers toolbox.  The main feature, the raison-d'etre, is
the UI editor.  Activate Kiln (usually by shaking the phone) and a UI editor
appears where you can add, modify, and remove views.

Why stop there!  There's a log panel, too, where you can send +CocoaLumberjack+
log messages!

And you're damn right it's extensible!  You can write new editors, register
custom views with kiln, and even add new panels, for instance maybe you need a
Bluetooth device scanner, or a way to check API requests.

Enjoy!
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