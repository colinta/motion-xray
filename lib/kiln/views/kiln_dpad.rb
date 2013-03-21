module Kiln

  class KilnDpad < UIView

    def initWithFrame(frame)
      super.tap do
        @pressed = {
          up: 'kiln_dpad_up'.uiimage,
          down: 'kiln_dpad_down'.uiimage,
          left: 'kiln_dpad_left'.uiimage,
          right: 'kiln_dpad_right'.uiimage,
          center: 'kiln_dpad_center'.uiimage,
        }
        @default = 'kiln_dpad'.uiimage
        @image_view = 'kiln_dpad'.uiimageview
        @pressing = nil
        self << @image_view
      end
    end

    def set_pressing_image(direction)
      image = @pressed[direction] || @default
      @image_view.image = image
    end

    def get_pressing(point)
      center = CGRect.new([24.5, 24.5], [23.0, 23.0])
      pressing = nil
      if not self.bounds.contains? point
        return nil
      elsif center.contains? point
        return :center
      else
        if point.x < point.y
          if point.x < self.frame.height - point.y
            return :left
          else
            return :down
          end
        else
          if point.x < self.frame.height - point.y
            return :up
          else
            return :right
          end
        end
      end
    end

    def targets
      @targets ||= []
    end

    def add_listener(target, action)
      targets << [target, action]
    end

    def fire(delta)
      if delta.is_a?(Symbol)
        dx = 0
        dy = 0
        case delta
        when :up
          dy = -1
        when :down
          dy = 1
        when :left
          dx = -1
        when :right
          dx = 1
        when :center
          # pass
        else
          raise "huh? #{delta.inspect}"
        end
        delta = CGPoint.new(dx, dy)
      end

      targets.each { |target, action| target.send(action, delta) }
    end

    def touchesBegan(touches, withEvent:event)
      super
      point = touches.anyObject.locationInView(self)

      @pressing = get_pressing(point)
      @was_pressing = true
      @started_location = point
      if @pressing != :center
        @started_time = NSDate.new.to_i
        @started_timer = 0.1.every do
          new_time = NSDate.new.to_i
          delta = new_time - @started_time
          break if delta < 0.5

          if @was_pressing
            fire(@pressing)
          end
        end
        fire(@pressing)
      end
      set_pressing_image(@pressing)
    end

    def touchesMoved(touches, withEvent:event)
      super
      return unless @pressing

      point = touches.anyObject.locationInView(self)
      if @pressing == :center
        dx = point.x - @started_location.x
        dy = point.y - @started_location.y
        fire(CGPoint.new(dx, dy))
        @started_location = point
      else
        if get_pressing(point) != @pressing
          @was_pressing = false
          set_pressing_image(nil)
        else
          @was_pressing = true
          set_pressing_image(@pressing)
        end
      end
    end

    def touchesEnded(touches, withEvent:event)
      super
      @started_timer.invalidate if @started_timer
      set_pressing_image(nil)
      @started_timer = nil
    end

    def touchesCancelled(touches, withEvent:event)
      super
      @started_timer.invalidate if @started_timer
      set_pressing_image(nil)
      @started_timer = nil
    end

  end

end
