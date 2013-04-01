module Motion ; module Xray

  class AccessibilityPlugin < Plugin
    name 'Accessibility'

    def plugin_view(canvas)
      return UIView.alloc.initWithFrame(canvas.bounds).tap do |view|
        view.backgroundColor = :black.uicolor

        @colorblind = UIButton.alloc.initWithFrame(view.bounds
          .thinner(view.bounds.width / 2)
          .right(view.bounds.width / 2))
        @accessibility = UIButton.alloc.initWithFrame(view.bounds
          .thinner(view.bounds.width / 2))

        @big_image = UIButton.alloc.initWithFrame(Xray.window.bounds)
        @big_image.backgroundColor = :black.uicolor
        @big_image.on :touch {
          @big_image.fade_out_and_remove
        }

        @colorblind.on :touch {
          show_big_colorblind(@colorblind.imageForState(:normal.uicontrolstate))
        }

        @accessibility.on :touch {
          show_big_colorblind(@accessibility.imageForState(:normal.uicontrolstate))
        }

        @colorblind_spinner = UIActivityIndicatorView.white
        @colorblind_spinner.center = @colorblind.center
        @colorblind_spinner.hidesWhenStopped
        @colorblind_spinner.stopAnimating

        @accessibility_spinner = UIActivityIndicatorView.white
        @accessibility_spinner.center = @accessibility.center
        @accessibility_spinner.hidesWhenStopped
        @accessibility_spinner.stopAnimating

        view << @colorblind_spinner
        view << @accessibility_spinner
        view << @colorblind
        view << @accessibility
      end
    end

    def show
      @colorblind.setImage(nil, forState: :normal.uicontrolstate)
      @accessibility.setImage(nil, forState: :normal.uicontrolstate)
      @colorblind_spinner.startAnimating
      @accessibility_spinner.startAnimating

      Dispatch::Queue.concurrent(:default).async do
        image = get_colorblind_image
        Dispatch::Queue.main.async do
          @colorblind.setImage(image, forState: :normal.uicontrolstate)
          @colorblind_spinner.stopAnimating
        end
      end
      Dispatch::Queue.concurrent(:default).async do
        image = get_accessibility_image
        Dispatch::Queue.main.async do
          @accessibility.setImage(image, forState: :normal.uicontrolstate)
          @accessibility_spinner.stopAnimating
        end
      end
    end

    def get_colorblind_image
      Xray.ui.get_screenshot.darken(brightness:-0.1, saturation:0)
    end

    def get_accessibility_image
      views = Xray.ui.collect_visible_views.map {|view|
        # if the view "is accessible", draw a green square
        # otherwise a red one
        f = view.convertRect(view.bounds, toView:nil)
        f.origin.x *= 2
        f.origin.y *= 2
        f.size.width *= 2
        f.size.height *= 2
        retval = UIView.alloc.initWithFrame(f)

        if is_accessible?(view)
          retval.backgroundColor = good_color
        else
          retval.backgroundColor = bad_color
        end
        retval
      }

      scale = UIScreen.mainScreen.scale
      UIGraphicsBeginImageContextWithOptions(Xray.window.bounds.size, false, scale)
      context = UIGraphicsGetCurrentContext()

      views.reverse.each do |subview|
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, subview.frame.origin.x, subview.frame.origin.y)
        subview.layer.renderInContext(context)
        CGContextRestoreGState(context)
      end
      image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      return image
    end

    def is_accessible?(view)
      !!view.accessibilityLabel
    end

    def good_color
      :green.uicolor(0.5)
    end

    def bad_color
      :red.uicolor(0.1)
    end

    def show_big_colorblind(image)
      @big_image.setImage(image, forState: :normal.uicontrolstate)
      @big_image.alpha = 0
      Xray.window << @big_image
      @big_image.fade_in {
      }
    end

  end

end end
