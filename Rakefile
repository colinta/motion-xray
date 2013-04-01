# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler'
Bundler.require


Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'kiln'

  app.pods do
    pod 'CocoaLumberjack'
  end

  app.resources_dirs << 'lib/resources'
  app.detect_dependencies = false
end
