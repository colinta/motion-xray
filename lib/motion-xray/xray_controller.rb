# @requires Motion::Xray
module Motion::Xray

  class XrayController

    def layout
      @layout ||= begin
        layout = XrayLayout.new

        layout.on :activate do
          self.activate
        end
        layout.on :deactivate do
          self.deactivate
        end
      end
    end

    def toggle
      if active?
        cool_down
      else
        fire_up
      end

      return active?
    end

    def active?
      @active
    end

    def fire_up
      return if @active
      @active = true

      self.layout.fire_up

      XrayFireUpNotification.post_notification
    end

    def activate
      return if @activated
      self.layout.activate
      @activated = true
    end

    def deactivate
      return unless @activated
      self.layout.deactivate
      @activated = false
    end

    def cool_down
      return unless @active
      @active = false

      self.deactivate
      self.layout.cool_down

      XrayCoolDownNotification.post_notification
    end

    def shutdown
      self.layout.shutdown
    end

  end

end
