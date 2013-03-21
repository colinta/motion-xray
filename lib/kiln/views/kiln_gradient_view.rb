module Kiln

  class KilnGradientView < UIView
    attr_accessor :start_color
    attr_accessor :final_color

    def drawRect(rect)
      context = UIGraphicsGetCurrentContext()
      color_space = CGColorSpaceCreateDeviceRGB()
      cgcolors = [
        (start_color || :white).uicolor.CGColor,
        (final_color || :lightgray).uicolor.CGColor,
      ]

      points = [0, 1]

      gradient = CGGradientCreateWithColors(color_space, cgcolors, points.to_pointer(:float))
      CGContextDrawLinearGradient(context, gradient, self.bounds.top_left, self.bounds.bottom_left, 0)
    end

  end

end
