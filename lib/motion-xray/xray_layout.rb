module Motion ; module Xray

  class XrayViewController < UIViewController

    def loadView
      @layout = Xray.layout
      self.view = @layout.view
    end

    def willAnimateRotationToInterfaceOrientation(orientation, duration:duration)
      @layout.reapply!
    end

  end

  class XrayLayout < MK::Layout

    def initialize
      super()
    end

    def toggle
      if fired?
        cool_down
      else
        fire_up
      end

      return fired?
    end

    def fired?
      @fired
    end

    def fire_up
      return if @fired
      @fired = true

      Xray.first_responder && Xray.first_responder.resignFirstResponder

      # gather all window subviews into 'revert_view'
      @revert = {
        views: [],
        status_bar_was_hidden?: Xray.app_shared.statusBarHidden?,
        transforms: {}
      }

      Xray.window.subviews.each do |subview|
        @revert[:views] << subview
        @revert[:transforms][subview] = subview.layer.transform
      end
      @old_controller = Xray.window.rootViewController
      @revert[:views].each do |view|
        # @tiny_view << view
      end
      Xray.app_shared.setStatusBarHidden(true, withAnimation:UIStatusBarAnimationSlide)
      Xray.window.rootViewController = @xray_controller
    end

    def cool_down
      return unless @fired
      @fired = false

      @revert[:views].each do |subview|
        Xray.window << subview
        UIView.animate {
          # identity matrix
          subview.layer.transform = @revert[:transforms][subview]
          subview.layer.anchorPoint = [0.5, 0.5]
        }
      end
      Xray.app_shared.setStatusBarHidden(@revert[:status_bar_was_hidden?], withAnimation:UIStatusBarAnimationSlide)
      @revert = nil
    end

    def layout
      root(UIView) do
        frame Xray.window.bounds
      end
    end

    def collect_visible_views(view=nil)
      if view
        # join all the subviews
        view.xray_subviews.reverse.map { |subview|
          collect_visible_views(subview)
        }.flatten + [view]
      else
        # start at the revert[:views] and collect all subviews
        @revert[:views].reverse.map { |subview|
          collect_visible_views(subview)
        }.flatten.select { |subview| !subview.hidden? }
      end
    end

  end

end end
