# @requires Motion::Xray
module Motion::Xray

  class XrayWindow < UIWindow

    def motionEnded(motion, withEvent:event)
      if RUBYMOTION_ENV == 'development' && event.type == UIEventSubtypeMotionShake
        Motion::Xray.toggle
      else
        super
      end
    end

  end

end
