module Kiln

  class ColorEditor < PropertyEditor

    def initialize(target, property)
      super

      canvas_bounds = Kiln.ui.bottom_half.frame
      @color_editor_margin = 20
      @color_editor_view = UIView.alloc.initWithFrame(App.window.bounds).tap do |color_editor_view|
        close_editor_control = UIControl.alloc.initWithFrame(color_editor_view.bounds)
        close_editor_control.on :touch do
          # touching outside
          self.close_color_editor
        end
        color_editor_view << close_editor_control

        color_editor_view << UIView.alloc.initWithFrame(canvas_bounds.shrink(@color_editor_margin)).tap do |background|
          background.layer.cornerRadius = 5
          background.layer.borderWidth = 1
          background.layer.borderColor = :dimgray.uicolor.cgcolor
          background.backgroundColor = :black.uicolor

          @color_sliders = ColorSliders.alloc.initWithFrame(background.bounds.shrink(10))
          background << @color_sliders
          @color_sliders.on :change {
            color_did_change(@color_sliders.color)
          }
        end
      end
      @color_editor_view.frame = @color_editor_view.frame.right(App.bounds.width)
      @color_editor_view.fade_out
    end

    def edit_view(rect)
      UIView.alloc.initWithFrame([[0, 0], [rect.width, 34]]).tap do |view|
        color_size = CGSize.new(50, 24)
        @color_picker = ColorSwatch.alloc.initWithFrame([[4, 4], color_size])
        @color_picker.color = @original
        view << @color_picker

        @color_picker.on :touch do
          color_touched
        end

        label_x = color_size.width + 8
        label_view = UILabel.new.style(
          frame: [[label_x, 5], [rect.width - label_x, 18]],
          text: @property.to_s,
          font: :small,
          background: :clear,
          numberOfLines: 1,
        )
        view << label_view
      end
    end

    def color_touched
      @color_picker.userInteractionEnabled = false
      if @color_editor_view.superview
        close_color_editor
      else
        open_color_editor
      end
    end

    def open_color_editor
      # move it off screen before sliding it in
      App.window << @color_editor_view
      @color_editor_view.fade_in
      @color_editor_view.slide(:left) {
        @color_picker.userInteractionEnabled = true
      }
    end

    def close_color_editor
      @color_editor_view.fade_out
      @color_editor_view.slide(:left) {
        @color_editor_view.removeFromSuperview
        # move it off screen, ready to move back in
        @color_editor_view.frame = @color_editor_view.frame.x(App.bounds.width)
        @color_picker.userInteractionEnabled = true
      }
    end

    def color_did_change(color)
      KilnNotificationTargetDidChange.post_notification(@target, { 'property' => @property, 'value' => color })
      set_value(color)
    end

  end

end
