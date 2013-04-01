module Kiln
  module_function
  def ui
    unless @kiln_ui
      @kiln_ui ||= UI.new

      Symbol.css_colors[:kiln_dashboard_label_text] = :darkblue.uicolor
      Symbol.css_colors[:kiln_dashboard_label_border] = :lightblue.uicolor
      Symbol.css_colors[:kiln_dashboard_label_bg] = :ghostwhite.uicolor

      # register default plugins if this is the first time kiln_ui has been
      # accessed.  AKA "startup".  Default plugins get pushed to the front,
      # so they will appear in reverse order than they are here.
      [LogPlugin, AccessibilityPlugin, UIPlugin].each do |plugin_class|
        unless Kiln.plugins.any? { |plugin| plugin_class === plugin }
          Kiln.plugins.unshift(plugin_class.new)
        end
      end
    end
    return @kiln_ui
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
