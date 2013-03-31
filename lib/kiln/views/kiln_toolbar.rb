module Kiln

  # Toolbar is a terrible name.  It's more of a "tab bar", but that name was
  # taken.  Plus, I dunno, maybe I'll add other tools to it!
  class KilnToolbar < UIView
    attr_accessor :canvas
    attr_accessor :selected
    attr_accessor :delegate

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
        @selected_view = KilnSelectedToolbarItem.new
        @scroll_view << @selected_view

        @index = nil
        @toolbar_items = []
        @views = []
        @item_x = margin

        recognizer = UITapGestureRecognizer.alloc.initWithTarget(self, action:'tapped:')
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        self.addGestureRecognizer(recognizer)
      end
    end

    def tapped(event)
      touched_x = event.locationInView(self).x + @scroll_view.contentOffset.x
      touched_index = nil
      @toolbar_items.each_with_index do |item, index|
        if touched_x < item.frame.max_x
          touched_index = index
          break
        end
      end
      select(touched_index) if touched_index
    end

    def margin
      10
    end

    def add(name, plugin_view)
      toolbar_item = KilnToolbarItem.alloc.initWithText(name)
      toolbar_item.frame = toolbar_item.frame.right(@item_x).down(5)
      @item_x += toolbar_item.frame.width
      @item_x += margin
      @scroll_view << toolbar_item
      @scroll_view.contentSize = [@item_x, self.bounds.height]
      @toolbar_items << toolbar_item
      @views << plugin_view

      unless @index
        select(0)
      end
    end

    def select(index)
      toolbar_item = @toolbar_items[index]
      will_hide
      @index = index
      self.canvas.subviews.each &:removeFromSuperview
      UIView.animate {
        @selected_view.item = toolbar_item
      }
      will_show

      plugin_view = @views[@index]
      self.canvas << plugin_view

      if self.canvas.is_a?(UIScrollView)
        self.canvas.contentSize = plugin_view.frame.size
        self.canvas.setContentOffset([0, 0], animated: false)
      end
    end

    def show
      will_show
    end

    def will_hide
    end

    def will_show
    end

  end

  class PluginToolbar < KilnToolbar

    def initWithFrame(frame)
      super.tap do
        @plugin_items = []
        @selected = nil
      end
    end

    def add(plugin)
      name = plugin.kiln_name
      plugin_view = plugin.get_plugin_view(@canvas)
      @plugin_items << plugin
      super(name, plugin_view)
    end

    def will_hide
      @selected.hide if @selected
    end

    def will_show
      @selected = @plugin_items[@index]
      @selected.show if @selected
    end

  end

  class KilnSelectedToolbarItem < UIView
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

  class KilnToolbarItem < UILabel
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
