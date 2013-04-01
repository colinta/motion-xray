unless defined?(Motion::Project::Config)
  raise "The kiln gem must be required within a RubyMotion project Rakefile."
end

require 'sugarcube'
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

  Dir.glob(File.join(File.dirname(__FILE__), 'kiln/**/*.rb')).reverse.each do |file|
    app.files.insert(insert_point, file)
  end

  app.resources_dirs << File.join(File.dirname(__FILE__), 'resources')
  app.frameworks << 'MessageUI'
end
