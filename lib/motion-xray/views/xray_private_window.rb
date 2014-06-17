# @requires Motion::Xray
module Motion::Xray

  # This window is added to the application when Motion::Xray.fire_up is called,
  # and removed in Motion::Xray.cool_down
  class XrayPrivateWindow < UIWindow

    def initWithFrame(frame)
      frame.size.height = 40
      super(frame).tap do
        self.windowLevel = UIWindowLevelStatusBar - 1
      end
    end

    def motionEnded(motion, withEvent:event)
      if event.type == UIEventSubtypeMotionShake
        Motion::Xray.cool_down
      end
    end

  end

end
