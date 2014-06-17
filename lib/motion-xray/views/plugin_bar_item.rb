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

        size.width += plugin.icon.size.width + text_offset + padding * 2
        size.height = PluginsBar::HEIGHT

        size
      end

    end

    def initWithPlugin(plugin)
      size = PluginBarItem.size_of_plugin(plugin)

      f = CGRect.new([0, 0], size)
      initWithFrame(f).tap do
        @plugin = plugin
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

    def icon_view
      unless @icon_view
        @icon_view = UIImageView.alloc.initWithImage(plugin.icon)

        f = @icon_view.frame
        f.origin.x = PluginBarItem.padding
        f.origin.y = (self.height - plugin.icon.size.height) / 2
        @icon_view.frame = f
      end
      return @icon_view
    end

    def label
      unless @label
        attrd_label = @plugin.name.attrd(PluginBarItem.label_attributes)

        size = PluginBarItem.size_of_text(@plugin.name)
        f = CGRect.new([icon_view.x + icon_view.width + PluginBarItem.text_offset, 0], [size.width, self.height])

        @label = UILabel.alloc.initWithFrame(f)
        @label.attributedText = attrd_label
      end
      return @label
    end

  end

end
