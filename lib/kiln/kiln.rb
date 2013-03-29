module Kiln
  module_function
  def ui
    @kiln_ui ||= UI.new
  end

  def controller
    @kiln_controller ||= KilnViewController.new
  end

  def toggle
    Kiln.ui.toggle
  end

  def fire_up
    Kiln.ui.fire_up
  end

  def cool_down
    Kiln.ui.cool_down
  end

  def window
    UIApplication.sharedApplication.keyWindow || UIApplication.sharedApplication.windows[0]
  end

  def app_shared
    UIApplication.sharedApplication
  end

  def app_bounds
    UIScreen.mainScreen.bounds
  end

  def plugins
    @plugins ||= []
  end

  def register(plugin)
    Kiln.plugins << plugin
  end

end
