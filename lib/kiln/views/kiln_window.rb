module Kiln

  class Window < UIWindow

    def motionEnded(motion, withEvent:event)
      if event.type == UIEventSubtypeMotionShake
        Kiln.toggle
      end
    end

  end

end
