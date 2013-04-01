module Motion ; module Xray

  module_function
  def ui
    unless @xray_ui
      @xray_ui ||= UI.new

      # register default plugins if this is the first time xray_ui has been
      # accessed.  AKA "startup".  Default plugins get pushed to the front,
      # so they will appear in reverse order than they are here.
      [LogPlugin, AccessibilityPlugin, UIPlugin].each do |plugin_class|
        unless Xray.plugins.any? { |plugin| plugin_class === plugin }
          Xray.plugins.unshift(plugin_class.new)
        end
      end
    end
    return @xray_ui
  end

  def controller
    @xray_controller ||= XrayViewController.new
  end

  def toggle
    Xray.ui.toggle
  end

  def fire_up
    Xray.ui.fire_up
  end

  def cool_down
    Xray.ui.cool_down
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
    Xray.plugins << plugin
  end

end end
