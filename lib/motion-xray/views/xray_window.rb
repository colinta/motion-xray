module Motion ; module Xray

  class XrayWindow < UIWindow

    def motionEnded(motion, withEvent:event)
      if event.type == UIEventSubtypeMotionShake
        Xray.toggle
      end
    end

  end

end end
