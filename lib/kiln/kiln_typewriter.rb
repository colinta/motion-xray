module Kiln
  # Copied from the gem of the same name, but I didn't want the dependency
  class TypewriterView < UIView
    attr_accessor :scroll_view
    attr_accessor :background_view

    attr_accessor :vertical_spacing, :horizontal_spacing
    attr_accessor :top_margin, :bottom_margin
    attr_accessor :left_margin, :right_margin

    attr_accessor :centered
    attr_accessor :min_width, :min_height

    def initWithFrame(frame)
      super.tap do
        self.spacing = 0
        self.margin = 0
        self.centered = false
        self.min_width = nil
        self.min_height = nil
        self.contentMode = :bottom.uicontentmode

        @row = []
      end
    end

    def shrink
      self.frame = self.frame.height(0)
    end

    def expand
      self.frame = self.frame.height(self.subviews[0].frame.height)
    end

    def spacing=(spacing)
      if spacing.is_a? Array
        case spacing.length
        when 1
          self.spacing = spacing[0]
        when 2
          @horizontal_spacing = spacing[0]
          @vertical_spacing = spacing[1]
        end
      else
        @horizontal_spacing = @vertical_spacing = spacing
      end
    end

    def margin=(margins)
      margins = [margins] unless margins.is_a? Enumerable

      case margins.length
      when 1
        @top_margin = @bottom_margin = @left_margin = @right_margin = margins[0]
      when 2
        @top_margin = margins[0]
        @bottom_margin = margins[0]
        @left_margin = margins[1]
        @right_margin = margins[1]
      when 3
        @top_margin = margins[0]
        @bottom_margin = margins[0]
        @right_margin = margins[1]
        @left_margin = margins[2]
      when 4
        @top_margin = margins[0]
        @right_margin = margins[1]
        @bottom_margin = margins[2]
        @left_margin = margins[3]
      else
        raise "Too many arguments (#{margins.length}) sent to MarginView#margin"
      end

      margins
    end

    ##|  DEFAULTS
    def vertical_spacing
      @vertical_spacing ||= 0
      @vertical_spacing
    end
    def horizontal_spacing
      @horizontal_spacing ||= 0
      @horizontal_spacing
    end
    def top_margin
      @top_margin ||= 0
      @top_margin
    end
    def bottom_margin
      @bottom_margin ||= 0
      @bottom_margin
    end
    def left_margin
      @left_margin ||= 0
      @left_margin
    end
    def right_margin
      @right_margin ||= 0
      @right_margin
    end

    ##|
    ##|  START AT 0, 0, AND START FLOATING
    ##|
    def layoutSubviews
      super
      # super
      # the max_height of *all* the rows so far (not just the current row)
      @max_height = top_margin
      clear

      # when a row would be longer than this, it is wrapped to the next row.
      @max_x = self.frame.size.width - right_margin

      self.subviews.each do |view|
        unless view == @background_view
          view.setNeedsLayout
          view.layoutIfNeeded
          add_next(view)
        end
      end
      clear(true)  # don't add vertical spacing

      self.frame = [self.frame.origin, [self.frame.size.width, @y + bottom_margin]]
      if scroll_view
        scroll_view.scrollEnabled = (@y > scroll_view.frame.size.height)
        scroll_view.contentSize = self.frame.size
      end
      if background_view
        background_view.frame = self.bounds
      end
    end

    def setNeedsLayout
      super
    end

    def background_view=(view)
      @background_view.removeFromSuperview if @background_view && @background_view.superview == self
      view.frame = self.bounds
      self.insertSubview(view, atIndex:0)
      @background_view = view
    end

    private
    def clear(is_last_row=false)
      @x = left_margin
      @y = @max_height
      # only add the horizontal_spacing after at least one row has been written
      if @y > top_margin && ! is_last_row
        @y += vertical_spacing
      end

      if self.centered
        row_width = left_margin
        row_height = min_height || 0
        @row.each do |view|
          if row_width > 0
            row_width += horizontal_spacing
          end
          row_height = view.frame.size.height if view.frame.size.height > row_height
          row_width += view.frame.size.width
        end
        row_width += right_margin
        row_width = min_width if min_width and row_width < min_width
        x = ((self.frame.size.width - row_width) / 2).round

        @row.each do |view|
          frame = view.frame

          y = ((row_height - frame.size.height) / 2).round

          if x > 0 or y > 0
            frame.origin.x += x
            frame.origin.y += y
            view.frame = frame
          end
        end
      end
      @row = []
    end

    def add_next(subview)
      # this frame will get modified and reassigned
      subview_frame = subview.frame

      # move to the next new row?
      width = subview_frame.size.width
      if self.min_width and width < self.min_width
        width = self.min_width
      end

      next_x = @x + width
      # too big?
      if next_x > @max_x
        clear
        next_x = @x + width
      end

      # new max_height?
      height = subview_frame.size.height
      if self.min_height and height < self.min_height
        height = self.min_height
      end
      next_y = @y + height
      @max_height = next_y if next_y > @max_height

      subview_frame.origin.x = @x
      subview_frame.origin.y = @y
      @x = next_x + horizontal_spacing

      subview.frame = subview_frame
      @row.push subview
    end

  end
end
