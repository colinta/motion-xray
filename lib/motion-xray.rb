unless defined?(Motion::Project::Config)
  raise "The motion-xray gem must be required within a RubyMotion project Rakefile."
end

require 'sugarcube-core'
require 'sugarcube-image'
require 'geomotion'

Motion::Project::App.setup do |app|
  # scans app.files until it finds app/ (the default)
  # if found, it inserts just before those files, otherwise it will insert to
  # the end of the list
  insert_point = 0
  app.files.each_index do |index|
    file = app.files[index]
    if file =~ /^(?:\.\/)?app\//
      # found app/, so stop looking
      break
    end
    insert_point = index + 1
  end

  Dir.glob(File.join(File.dirname(__FILE__), 'motion-xray/z_editors/*.rb')).reverse.each do |file|
    app.files.insert(insert_point, file)
  end
  Dir.glob(File.join(File.dirname(__FILE__), 'motion-xray/views/*.rb')).reverse.each do |file|
    app.files.insert(insert_point, file)
  end
  Dir.glob(File.join(File.dirname(__FILE__), 'motion-xray/plugins/*.rb')).reverse.each do |file|
    app.files.insert(insert_point, file)
  end
  Dir.glob(File.join(File.dirname(__FILE__), 'motion-xray/*.rb')).reverse.each do |file|
    app.files.insert(insert_point, file)
  end

  app.resources_dirs << File.join(File.dirname(__FILE__), 'resources')
end
