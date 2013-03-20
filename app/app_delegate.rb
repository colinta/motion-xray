include SugarCube::Adjust


class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = Kiln::Window.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    ctlr = MyController.new
    first = UINavigationController.alloc.initWithRootViewController(ctlr)
    @window.rootViewController = first
    @window.makeKeyAndVisible

    Kiln.register(Kiln::LogPlugin.new)
    Kiln.register(Kiln::AccessibilityPlugin.new)

    true
  end
end


class MyController < UITableViewController

end
