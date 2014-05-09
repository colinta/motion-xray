class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = Motion::Xray::XrayWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    ctlr = MyController.new
    first = UINavigationController.alloc.initWithRootViewController(ctlr)
    @window.rootViewController = first
    @window.makeKeyAndVisible

    Motion::Xray.register(Motion::Xray::SaveUIPlugin.new)

    true
  end
end


class MyController < UIViewController

  def viewDidLoad
    self.view.backgroundColor = :black.uicolor

    bluebox = UIView.alloc.initWithFrame([[20, 84], [30, 30]])
    bluebox.backgroundColor = :blue.uicolor
    self.view << bluebox

    darkbox = UIView.alloc.initWithFrame(bluebox.frame.below(8))
    darkbox.backgroundColor = '#222222'.uicolor
    self.view << darkbox

    lightbox = UIView.alloc.initWithFrame(darkbox.frame.below(8))
    lightbox.backgroundColor = :white.uicolor
    self.view << lightbox

    label = UILabel.alloc.initWithFrame(lightbox.frame.below(8))
    label.backgroundColor = :clear.uicolor
    label.textColor = :white.uicolor
    label.text = 'A Label'
    label.sizeToFit
    self.view << label
  end

end
