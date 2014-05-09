# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'motion-kit'
require './lib/motion-xray'


Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'motion-xray'
  app.detect_dependencies = false
  app.frameworks << 'MessageUI'
  app.device_family = [:iphone, :ipad]
  app.info_plist['UIViewControllerBasedStatusBarAppearance'] = false
end
