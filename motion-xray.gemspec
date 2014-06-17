# -*- encoding: utf-8 -*-
require File.expand_path('../lib/motion-xray/version.rb', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'motion-xray'
  gem.version       = Motion::Xray::Version

  gem.authors = ['Colin T.A. Gray']
  gem.email   = ['colinta@gmail.com']
  gem.summary     = %{An in-app UI editing system for iOS}
  gem.description = <<-DESC
The simulator and RubyMotion REPL make on-device testing a painful cycle of
code, compile, check, repeat.  *Especially* when it comes to testing the UI,
where inexplicable differences can crop up between a device and the simulator.

Motion-Xray is an in-app developer's toolbox.  Activate Xray (usually by shaking the
phone) and a UI editor appears where you can add, modify, and remove views.

Why stop there!  There's a log panel, and an accessibility panel that gives you
a visiualization of how you app "looks" to the blind or color blind.

And you're damn right it's extensible!  You can write new UI editors, register
custom views, and add new panels, for instance maybe you need a Bluetooth device
scanner, or a way to check API requests.

Enjoy!
DESC

  gem.homepage    = 'https://github.com/colinta/motion-xray'

  gem.files       = Dir.glob('lib/**/*.rb')
  gem.files      << 'README.md'
  gem.test_files  = Dir.glob('spec/**/*.rb')

  gem.require_paths = ['lib']

  gem.add_dependency 'dbt'
  gem.add_dependency 'sweet-kit'
  gem.add_dependency 'motion-kit-events'
  gem.add_development_dependency 'awesome_print_motion'
end
