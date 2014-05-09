module Motion
  # This is the main interface that you'll need to use from in your app.
  #
  # Some useful methods:
  # - `Motion::Xray.fire_up` to show
  # - `Motion::Xray.cool_down` to hide
  # - `Motion::Xray.toggle` to do what it says on the tin
  # - `Motion::Xray.register(plugin)` to add a plugin
  module Xray

    module_function
    def layout
      unless @xray_layout
        @xray_layout = XrayLayout.new

        # register default plugins if this is the first time xray_ui has been
        # accessed.  AKA "startup".  Default plugins get pushed to the front,
        # so they will appear in reverse order than they are here.
        [LogPlugin, AccessibilityPlugin, UIPlugin].each do |plugin_class|
          unless Xray.plugins.any? { |plugin| plugin_class === plugin }
            Xray.plugins.unshift(plugin_class.new)
          end
        end
      end
      return @xray_layout
    end

    def controller
      @xray_controller ||= XrayViewController.new
    end

    def toggle
      Xray.layout.toggle
    end

    def fire_up
      Xray.layout.fire_up
    end

    def cool_down
      Xray.layout.cool_down
    end

    def window
      UIApplication.sharedApplication.keyWindow || UIApplication.sharedApplication.windows[0]
    end

    def first_responder
      _find_first_responder(Xray.window)
    end

    def _find_first_responder(view)
      if view.firstResponder?
        return view
      end

      found = nil
      view.subviews.each do |subview|
        found = _find_first_responder(subview)
        break if found
      end

      return found
    end

    def app_shared
      UIApplication.sharedApplication
    end

    def app_bounds
      UIScreen.mainScreen.bounds
    end

    def take_screenshot(view)
      UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, view.scale)
      view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
      image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      return image
    end

    def plugins
      @plugins ||= []
    end

    def register(plugin)
      Xray.plugins << plugin
    end

    def dashboard_label_text_color
      @dashboard_label_text_color ||= UIColor.colorWithRed(0, green: 0, blue: 139 / 255.0)
    end

end end


XrayTargetDidChangeNotification = 'Motion::Xray::TargetDidChangeNotification'

