# @provides Motion::Xray
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

    def private_window
      @private_window ||= begin
        # register default plugins if this is the first time the window has been
        # accessed.  AKA "startup".  Default plugins get pushed to the front, so
        # they will appear in reverse order than they are here.
        [InspectPlugin].each do |plugin_class|
          Motion::Xray.plugins << plugin_class.new
        end

        XrayPrivateWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
      end
    end

    def controller
      @xray_controller ||= XrayController.new
    end

    def toggle
      controller.toggle
    end

    def fire_up
      controller.fire_up
    end

    def cool_down
      controller.cool_down
    end

    def shutdown
      controller.shutdown
    end

    def window
      @window ||= UIApplication.sharedApplication.keyWindow || UIApplication.sharedApplication.windows[0]
    end

    def app
      UIApplication.sharedApplication
    end

    def app_bounds
      UIScreen.mainScreen.bounds
    end

    def take_screenshot(view)
      scale = UIScreen.mainScreen.scale
      UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale)
      view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: false)
      image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      return image
    end

    def plugins
      @plugins ||= []
    end

    def register(plugin)
      plugins << plugin
    end

    def status_action(text=nil, save=false, &action)
      return @status_action unless action

      @status_was ||= []
      if save
        @status_was << [
          @status_text,
          @status_action,
        ]
      end

      self.controller.layout.status_bar.text = text

      @status_text = text
      @status_action = action
    end

    def restore_status
      if @status_was && ! @status_was.empty?
        text, action = @status_was.pop
        self.controller.layout.status_bar.text = text

        @status_text = text
        @status_action = action
      end
    end

  end

end


XrayTargetDidChangeNotification = 'Motion::Xray::TargetDidChangeNotification'
XrayFireUpNotification = 'Motion::Xray::FireUpNotification'
XrayCoolDownNotification = 'Motion::Xray::CoolDownNotification'

