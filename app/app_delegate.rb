include SugarCube::Adjust


class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    ctlr = MyController.new
    first = UINavigationController.alloc.initWithRootViewController(ctlr)
    @window.rootViewController = first
    @window.makeKeyAndVisible

    0.2.seconds.later { Kiln.fire_up }
    true
  end
end


class MyController < UITableViewController

  def viewWillAppear(animated)
    super
    self.becomeFirstResponder
  end

  def canBecomeFirstResponder
    true
  end

  def motionEnded(motion, withEvent:event)
    if event.type == UIEventSubtypeMotionShake
      Kiln.toggle
    end
  end

end
