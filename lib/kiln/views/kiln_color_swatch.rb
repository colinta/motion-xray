module Kiln

  class ColorSwatch < UIControl

    def initWithFrame(frame)
      super.tap do
        gradient_view = GradientView.alloc.initWithFrame(self.bounds).tap do |gradient_view|
          gradient_view.layer.borderWidth = 1
          gradient_view.layer.borderColor = :gray.uicolor.CGColor
          gradient_view.userInteractionEnabled = false
        end
        self << gradient_view

        swatch_rect = gradient_view.bounds.shrink(3)

        gradient_view << TriangleSwatch.alloc.initWithFrame(swatch_rect)

        @color_swatch = UIView.alloc.initWithFrame(swatch_rect).tap do |color_swatch|
          color_swatch.layer.borderWidth = 1
          color_swatch.layer.borderColor = :dimgray.uicolor.CGColor
        end
        gradient_view << @color_swatch

        @pressed_shader = UIView.alloc.initWithFrame(self.bounds).tap do |pressed_shader|
          pressed_shader.backgroundColor = :black.uicolor(0.5)
          pressed_shader.hide
        end
        self << @pressed_shader

        self.on :touch_start do
          @pressed_shader.show
        end
        self.on :touch_stop do
          @pressed_shader.hide
        end
      end
    end

    def color=(value)
      @color_swatch.backgroundColor = value && value.uicolor
    end

    def color
      @color_swatch.backgroundColor
    end

  end

  class TriangleSwatch < UIView

    def drawRect(rect)
      context = UIGraphicsGetCurrentContext()

      path = UIBezierPath.bezierPath
      path.moveToPoint(bounds.top_right)
      path.addLineToPoint(bounds.bottom_right)
      path.addLineToPoint(bounds.bottom_left)
      CGContextAddPath(context, path.CGPath)
      :black.uicolor.setFill
      CGContextFillPath(context)

      path = UIBezierPath.bezierPath
      path.moveToPoint(bounds.bottom_left)
      path.addLineToPoint(bounds.top_left)
      path.addLineToPoint(bounds.top_right)
      CGContextAddPath(context, path.CGPath)
      :white.uicolor.setFill
      CGContextFillPath(context)
    end

  end

  class ColorSliders < UIControl
    attr_reader :color

    def initWithFrame(frame)
      super.tap do
        self.backgroundColor = :black.uicolor
        @color = :clear.uicolor
        @triangle = TriangleSwatch.alloc.initWithFrame(CGRect.empty)
      end
    end

    def color=(value)
      @color = value.uicolor
      setNeedsDisplay
    end

    def drawRect(rect)
      super

      r = color.red
      g = color.green
      b = color.blue
      a = color.alpha
      return unless r && g && b && a

      context = UIGraphicsGetCurrentContext()
      color_space = CGColorSpaceCreateDeviceRGB()
      slider_height = bounds.height / 5
      slider_size = bounds.size
      slider_size.height = slider_height
      path = UIBezierPath.bezierPathWithRect([[0, 0], slider_size])
      @triangle.frame = [[0, 0], slider_size]
      @triangle.drawRect(rect)

      CGContextSaveGState(context)
      CGContextTranslateCTM(context, 0, 0)
      color.setFill
      path.fill
      CGContextRestoreGState(context)

      big_oval_width = slider_height - 4
      big_oval = [[-big_oval_width / 2, (slider_height - big_oval_width) / 2], [big_oval_width, big_oval_width]]
      big_oval_path = UIBezierPath.bezierPathWithOvalInRect(big_oval)
      small_oval_width = 4
      small_oval = [[-small_oval_width / 2, (slider_height - small_oval_width) / 2], [small_oval_width, small_oval_width]]
      small_oval_path = UIBezierPath.bezierPathWithOvalInRect(small_oval)

      points = [0, 1].to_pointer(:float)

      cgcolors_red = [
        UIColor.colorWithRed(0, green:g, blue:b, alpha:1).CGColor,
        UIColor.colorWithRed(1, green:g, blue:b, alpha:1).CGColor,
      ]
      gradient_red = CGGradientCreateWithColors(color_space, cgcolors_red, points)
      CGContextSaveGState(context)
      CGContextTranslateCTM(context, 0, 1 * slider_height)
      path.addClip
      CGContextDrawLinearGradient(context, gradient_red, self.bounds.top_left, self.bounds.top_right, 0)
      CGContextTranslateCTM(context, r * bounds.width, 0)
      UIColor.colorWithRed(1, green:g, blue:b, alpha:1).invert.setStroke
      big_oval_path.stroke
      small_oval_path.stroke
      CGContextRestoreGState(context)

      cgcolors_green = [
        UIColor.colorWithRed(r, green:0, blue:b, alpha:1).CGColor,
        UIColor.colorWithRed(r, green:1, blue:b, alpha:1).CGColor,
      ]
      gradient_green = CGGradientCreateWithColors(color_space, cgcolors_green, points)
      CGContextSaveGState(context)
      CGContextTranslateCTM(context, 0, 2 * slider_height)
      path.addClip
      CGContextDrawLinearGradient(context, gradient_green, self.bounds.top_left, self.bounds.top_right, 0)
      CGContextTranslateCTM(context, g * bounds.width, 0)
      UIColor.colorWithRed(r, green:1, blue:b, alpha:1).invert.setStroke
      big_oval_path.stroke
      small_oval_path.stroke
      CGContextRestoreGState(context)

      cgcolors_blue = [
        UIColor.colorWithRed(r, green:g, blue:0, alpha:1).CGColor,
        UIColor.colorWithRed(r, green:g, blue:1, alpha:1).CGColor,
      ]
      gradient_blue = CGGradientCreateWithColors(color_space, cgcolors_blue, points)
      CGContextSaveGState(context)
      CGContextTranslateCTM(context, 0, 3 * slider_height)
      path.addClip
      CGContextDrawLinearGradient(context, gradient_blue, self.bounds.top_left, self.bounds.top_right, 0)
      CGContextTranslateCTM(context, b * bounds.width, 0)
      UIColor.colorWithRed(r, green:g, blue:1, alpha:1).invert.setStroke
      big_oval_path.stroke
      small_oval_path.stroke
      CGContextRestoreGState(context)

      cgcolors_alpha = [
        UIColor.colorWithRed(r, green:g, blue:b, alpha:0).CGColor,
        UIColor.colorWithRed(r, green:g, blue:b, alpha:1).CGColor,
      ]
      gradient_alpha = CGGradientCreateWithColors(color_space, cgcolors_alpha, points)
      CGContextSaveGState(context)
      CGContextTranslateCTM(context, 0, 4 * slider_height)
      path.addClip
      CGContextDrawLinearGradient(context, gradient_alpha, self.bounds.top_left, self.bounds.top_right, 0)
      CGContextTranslateCTM(context, a * bounds.width, 0)
      :white.uicolor.mix_with(color.uicolor(1).invert, a).setStroke
      big_oval_path.stroke
      small_oval_path.stroke
      CGContextRestoreGState(context)
    end

    def touchesBegan(touches, withEvent:event)
      point = touches.anyObject.locationInView(self)
      @touched_section = nil
      touched_color_at(point)
    end

    def touchesMoved(touches, withEvent:event)
      point = touches.anyObject.locationInView(self)
      touched_color_at(point)
    end

    ColorSection = 0
    RedSection = 1
    GreenSection = 2
    BlueSection = 3
    AlphaSection = 4

    def touched_color_at(point)
      slider_height = bounds.height / 5
      section = (point.y / slider_height).floor
      amount = [[point.x / bounds.width, 0].max, 1].min

      # assigns @touched_section only the first time (in `touchesBegan()`)
      @touched_section ||= section
      # makes sure we're still touching the same section
      section = @touched_section
      return if section == ColorSection

      r = color.red
      g = color.green
      b = color.blue
      a = color.alpha

      case section
      when RedSection
        r = amount
      when GreenSection
        g = amount
      when BlueSection
        b = amount
      when AlphaSection
        amount = (amount * 100).round / 100.0
        a = amount
      end

      self.color = UIColor.colorWithRed(r, green:g, blue:b, alpha:a)
      self.sendActionsForControlEvents(:value_changed.uicontrolevent)
    end

  end

end
