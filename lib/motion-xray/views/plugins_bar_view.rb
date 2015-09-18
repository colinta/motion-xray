# @requires Motion::Xray
module Motion::Xray

  class PluginsBarView < UIScrollView
    HEIGHT = 44

    def initWithFrame(frame)
      super.tap do
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false

        left = 0
        Motion::Xray.plugins.each do |plugin|
          left = add_plugin(plugin, left)

          unless plugin == Motion::Xray.plugins.last
            left = add_line(left)
          end
        end
        self.contentSize = [left, self.height]
      end
    end

    def add_plugin(plugin, left)
      item = PluginBarItem.alloc.initWithPlugin(plugin)

      f = item.frame
      f.origin.x = left
      left += f.size.width
      item.frame = f

      self << item

      left
    end

    def add_line(left)
      line = UIView.alloc.initWithFrame([[left, 0], [1, self.height]])
      left += line.width
      line.backgroundColor = '#292929'.uicolor
      line.autoresizingMask = :flexible_height.uiautoresizemask
      self << line

      left
    end

  end

end