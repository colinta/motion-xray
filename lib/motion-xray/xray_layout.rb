# @requires Motion::Xray
module Motion::Xray

  class XrayLayout < MK::Layout

    view :background_container
    view :status_bar
    view :plugins_bar_bg

    def initialize(options={})
      options[:root] = Motion::Xray.private_window
      super(options)
    end

    def fire_up
      self.view.hidden = false
      self.view.makeKeyAndVisible
      @status_bar_style_was = Motion::Xray.app.statusBarStyle
      Motion::Xray.app.setStatusBarStyle(UIStatusBarStyleLightContent, animated: true)

      self.status_bar.y = 0
      self.status_bar.slide_from :top
      self.status_bar_activates
      self.plugins_bar_bg.hidden = true
    end

    def activate
      self.status_bar_deactivates

      self.view.height = UIScreen.mainScreen.bounds.size.height

      self.plugins_bar_bg.y = self.view.height - self.plugins_bar_bg.height
      self.plugins_bar_bg.slide_from :bottom
      self.plugins_bar_bg.hidden = false

      actual_height = self.view.height
      actual_width = self.view.width
      margin = 20
      desired_width = actual_width - margin * 2
      desired_height = actual_height - self.status_bar.height - self.plugins_bar_bg.height - margin * 2
      height_scale = desired_height / actual_height
      width_scale = desired_width / actual_width
      if height_scale < width_scale
        scale = height_scale
      else
        scale = width_scale
      end

      Motion::Xray.window.scale_to(scale)
      offset = (desired_height - Motion::Xray.window.height) / 2
      Motion::Xray.window.delta_to([0, offset])
    end

    def deactivate
      self.status_bar_activates
      self.plugins_bar_bg.slide :down

      self.view.height = 40
      Motion::Xray.window.scale_to(1)
      Motion::Xray.window.move_to([0, 0])
    end

    def cool_down
      Motion::Xray.app.setStatusBarStyle(@status_bar_style_was, animated: true)
      self.status_bar.slide :up do
        Motion::Xray.shutdown
      end
    end

    def shutdown
      self.view.hidden = true
    end

    def status_bar_activates
      Motion::Xray.status_action('Touch to open Motion::Xray', true) do
        trigger :activate
      end
    end

    def status_bar_deactivates
      Motion::Xray.status_action('Touch to close Motion::Xray', true) do
        trigger :deactivate
      end
    end

    def layout
      frame Motion::Xray.window.bounds
      autoresizing_mask :fill

      add StatusBarButton, :status_bar
      add UIView, :plugins_bar_bg do
        add PluginsBarView, :plugins_bar
      end

      self.status_bar.off :touch
      self.status_bar.on :touch do
        Motion::Xray.status_action && Motion::Xray.status_action.call
      end
    end

    def status_bar_style
      frame from_top(width: '100%', height: 40)
    end

    def plugins_bar_style
      frame width: '100%', height: PluginsBarView::HEIGHT
    end

    def plugins_bar_bg_style
      frame from_bottom(width: '100%', height: PluginsBarView::HEIGHT)
      gradient do
        startPoint [0, 1]
        endPoint [0, 0]
        colors ['#353535'.uicolor, '#494949'.uicolor]
      end
    end

  end

end
