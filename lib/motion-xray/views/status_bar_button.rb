# @requires Motion::Xray
module Motion::Xray

  class StatusBarButton < UIControl
    BG_COLOR = '#095ffe'.uicolor(0.8)
    BG_COLOR_HIGHLIGHTED = '#0a3adf'.uicolor

    def initWithFrame(frame)
      super.tap do
        self.backgroundColor = BG_COLOR

        @label = UILabel.new
        @label.opaque = false
        @label.backgroundColor = :clear.uicolor
        @label.textColor = :white.uicolor
        @label.text = ''
        @label.textAlignment = :center.nstextalignment
        @label.font = 'Avenir-Roman'.uifont(12)
        @label.autoresizingMask = :fill_top.uiautoresizemask
        self << @label

        self.on :touch_start do
          self.backgroundColor = BG_COLOR_HIGHLIGHTED
        end
        self.on :touch_stop do
          self.backgroundColor = BG_COLOR
        end
      end
    end

    def layoutSubviews
      label_frame = self.bounds
      label_frame.size.height = 20
      label_frame.origin.y = self.height - label_frame.size.height
      @label.frame = label_frame
    end

    def text=(value)
      @label.text = value
    end

    def text
      @label.text
    end

  end

end
