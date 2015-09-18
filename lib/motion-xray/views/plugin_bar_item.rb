# @requires Motion::Xray
module Motion::Xray

  class PluginBarItem < UIControl
    attr :plugin

    class << self

      def label_attributes
        {
          NSBackgroundColorAttributeName => UIColor.clearColor,
          NSForegroundColorAttributeName => '#8C8C8C'.uicolor,
          NSFontAttributeName            => 'Avenir-Roman'.uifont(15),
        }
      end

      # space between icon and text
      def text_offset
        4
      end

      # outer space
      def padding
        8
      end

      def size_of_text(name)
        size = name.attrd(label_attributes).size
        size.width = size.width.ceil
        size.height = size.height.ceil
        size
      end

      def size_of_plugin(plugin)
        size = size_of_text(plugin.name)

        size.width += padding * 2
        if plugin.icon
          size.width += plugin.icon.size.width + text_offset
        end
        size.height = PluginsBarView::HEIGHT

        size
      end

    end

    def initWithPlugin(plugin)
      size = PluginBarItem.size_of_plugin(plugin)

      f = CGRect.new([0, 0], size)
      initWithFrame(f).tap do
        @plugin = plugin
        self << bg_view
        self << icon_view
        self << label

        self.on :touch_start do
          self.backgroundColor = :black.uicolor(0.5)
        end

        self.on :touch_stop do
          self.backgroundColor = :clear.uicolor
        end
      end
    end

    def willMoveToWindow(window)
      if window
        unless @observing
          self.addObserver(self,
            forKeyPath: 'selected',
            options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial,
            context: nil
            )
          @observing = true
        end
      else
        self.removeObserver(self, forKeyPath: 'selected')
        @observing = false
      end
    end

    def observeValueForKeyPath(path, ofObject: target, change: change, context: context)
      if path == 'selected'
        selected = change[NSKeyValueChangeNewKey]
        @bg_view.hidden = !selected
      end
    end

    def bg_view
      unless @bg_view
        @bg_view = UIView.alloc.initWithFrame(self.bounds)
        @bg_view.autoresizingMask = :fill.uiautoresizemask
        @bg_view.backgroundColor = :black.uicolor(0.5)
        @bg_view.hidden = !selected?
      end
      return @bg_view
    end

    def icon_view
      unless @icon_view
        @icon_view = UIImageView.alloc.initWithImage(plugin.icon)

        f = @icon_view.frame
        f.origin.x = PluginBarItem.padding
        if plugin.icon
          f.origin.y = (self.height - plugin.icon.size.height) / 2
        end
        @icon_view.frame = f
      end
      return @icon_view
    end

    def label
      unless @label
        attrd_label = @plugin.name.attrd(PluginBarItem.label_attributes)

        size = PluginBarItem.size_of_text(@plugin.name)
        f = CGRect.new([0, 0], [size.width, self.height])
        if @plugin.icon
          f.origin.x = CGRectGetMaxX(icon_view.frame) + PluginBarItem.text_offset
        else
          f.origin.x = PluginBarItem.padding
        end

        @label = UILabel.alloc.initWithFrame(f)
        @label.attributedText = attrd_label
      end
      return @label
    end

  end

end
