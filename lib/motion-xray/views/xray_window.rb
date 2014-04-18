module Motion ; module Xray

  class XrayWindow < UIWindow

    def motionEnded(motion, withEvent:event)
      if RUBYMOTION_ENV == 'development' && event.type == UIEventSubtypeMotionShake
        Xray.toggle
      else
        super
      end
    end

  end

end end
