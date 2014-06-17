class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = Motion::Xray::XrayWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    ctlr = MyController.new
    first = UINavigationController.alloc.initWithRootViewController(ctlr)
    @window.rootViewController = first
    @window.makeKeyAndVisible

    true
  end
end


class MyController < UIViewController

  def loadView
    @layout = MyLayout.new
    self.view = @layout.view
  end

end


class MyLayout < MK::Layout

  def layout
    backgroundColor :black

    add UIControl, :bluebox do
      frame [[20, 84], [30, 30]]
      backgroundColor :blue
      on :touch_start do
        self.get(:bluebox).backgroundColor = :darkblue.uicolor
      end
      on :touch_stop do
        self.get(:bluebox).backgroundColor = :blue.uicolor
      end
    end

    add UIControl, :darkbox do
      frame below(:bluebox, down: 8, size: [30, 30])
      backgroundColor '#222'
      on :touch_start do
        self.get(:darkbox).backgroundColor = '#000'.uicolor
      end
      on :touch_stop do
        self.get(:darkbox).backgroundColor = '#222'.uicolor
      end
    end

    add UIControl, :lightbox do
      frame below(:darkbox, down: 8, size: [30, 30])
      backgroundColor :white
      on :touch_start do
        self.get(:lightbox).backgroundColor = :light_gray.uicolor
      end
      on :touch_stop do
        self.get(:lightbox).backgroundColor = :white.uicolor
      end
    end

    add UILabel, :label do
      frame below(:lightbox, down: 8)
      backgroundColor :clear
      textColor :white
      text 'A Label'
      sizeToFit
    end
  end

end
