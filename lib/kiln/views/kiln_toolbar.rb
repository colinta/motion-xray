module Kiln

  # Toolbar is a terrible name.  It's more of a "tab bar", but that name was
  # taken.  Plus, I dunno, maybe I'll add other tools to it!
  class Toolbar < UIView
    attr_accessor :canvas
    attr_accessor :selected

    def initWithFrame(frame)
      super.tap do
        self.backgroundColor = :white.uicolor
        self.layer.borderColor = :black.uicolor.cgcolor
        self.layer.borderWidth = 1
        grad_layer = CAGradientLayer.layer
        grad_layer.frame = self.layer.bounds
        grad_layer.colors = [0x526691.uicolor.cgcolor, 0x27386e.uicolor.cgcolor]
        self.layer << grad_layer

        @scroll_view = UIScrollView.alloc.initWithFrame(bounds)
        self << @scroll_view
        @selected_view = SelectedToolbarItem.new
        @scroll_view << @selected_view

        @selected = nil
        @plugin_items = []
        @item_x = margin

        recognizer = UITapGestureRecognizer.alloc.initWithTarget(self, action:'tapped:')
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.addGestureRecognizer(recognizer)
      end
    end

    def tapped(event)
      touched_x = event.locationInView(self).x + @scroll_view.contentOffset.x
      touched = nil
      @plugin_items.each_with_index do |items, index|
        item = items[0]
        if touched_x < item.frame.max_x
          touched = index
          break
        end
      end
      select(touched) if touched
    end

    def margin
      10
    end

    def add(plugin)
      name = plugin.kiln_name
      plugin_view = plugin.get_kiln_view_in(@canvas)

      toolbar_item = ToolbarItem.alloc.initWithText(name)
      toolbar_item.frame = toolbar_item.frame.right(@item_x).down(5)
      @item_x += toolbar_item.frame.width
      @item_x += margin
      @scroll_view << toolbar_item
      @scroll_view.contentSize = [@item_x, self.bounds.height]
      @plugin_items << [toolbar_item, plugin]

      unless @selected
        select(0)
      end
    end

    def select(index)
      toolbar_item, plugin = @plugin_items[index]
      @selected = plugin

      UIView.animate {
        @selected_view.item = toolbar_item
      }
      self.canvas.subviews.each &:removeFromSuperview
      self.canvas << plugin.view
    end

  end

  class SelectedToolbarItem < UIView
    attr :item

    def initWithFrame(frame)
      super.tap do
        self.backgroundColor = :clear.uicolor
        @item = nil
      end
    end

    def item=(item)
      @item = item
      f = item.frame
      f.origin.x -= corner_radius
      f.origin.y -= corner_radius / 2
      f.size = item.size
      f.size.width += corner_radius * 2
      f.size.height += corner_radius
      self.frame = f
      setNeedsDisplay
    end

    def corner_radius
      5
    end

    def drawRect(rect)
      :white.uicolor.setFill
      UIBezierPath.bezierPathWithRoundedRect(bounds, cornerRadius:corner_radius).fill
    end

  end

  class ToolbarItem < UILabel
    attr :name

    def initWithText(text)
      initWithFrame(CGRect.empty).tap do
        self.backgroundColor = :clear.uicolor
        self.font = :label.uifont(12)
        self.text = text
        sizeToFit
      end
    end

  end

end
