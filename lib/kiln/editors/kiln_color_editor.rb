module Kiln

  class ColorEditor < PropertyEditor

    def edit_view(rect)
      canvas_bounds = Kiln.ui.bottom_half.frame
      @color_editor_margin = 20
      @color_editor_modal = UIView.alloc.initWithFrame(Kiln.window.bounds).tap do |color_editor_modal|
        close_editor_control = UIControl.alloc.initWithFrame(color_editor_modal.bounds)
        close_editor_control.on :touch do
          # touching outside
          self.close_color_editor
        end
        color_editor_modal << close_editor_control

        color_editor_modal << UIView.alloc.initWithFrame(canvas_bounds.shrink(@color_editor_margin)).tap do |background|
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
      @color_editor_modal.frame = @color_editor_modal.frame.right(Kiln.app_bounds.width)
      @color_editor_modal.fade_out

      return UIView.alloc.initWithFrame([[0, 0], [rect.width, 34]]).tap do |view|
        color_size = CGSize.new(50, 24)
        @color_picker = ColorSwatch.alloc.initWithFrame([[4, 4], color_size])
        @color_picker.color = get_value
        view << @color_picker

        @color_picker.on :touch do
          open_color_editor
        end

        label_x = color_size.width + 8
        @label_view = UILabel.new.style(
          frame: [[label_x, 5], [rect.width - label_x, 18]],
          font: :small,
          background: :clear,
          numberOfLines: 1,
        )
        view << @label_view
        update_views
      end
    end

    def open_color_editor
      @color_picker.userInteractionEnabled = false
      # move it off screen before sliding it in
      Kiln.window << @color_editor_modal
      @color_sliders.color = get_value || :clear.uicolor
      @color_editor_modal.fade_in
      @color_editor_modal.slide(:left) {
        @color_picker.userInteractionEnabled = true
      }
    end

    def close_color_editor
      @color_picker.userInteractionEnabled = false
      @color_editor_modal.fade_out
      @color_editor_modal.slide(:left) {
        @color_editor_modal.removeFromSuperview
        # move it off screen, ready to move back in
        @color_editor_modal.frame = @color_editor_modal.frame.x(Kiln.app_bounds.width)
        @color_picker.userInteractionEnabled = true
      }
    end

    def update_views
      color = get_value
      @color_picker.color = color
      alpha = (color && color.alpha < 1 ? " (a" << color.alpha.to_s << ")" : '')
      @label_view.text = "#{@property}: #{color ? color.to_hex + alpha : 'nil'}"
    end

    def color_did_change(color)
      set_value(color)
      update_views
    end

  end

end
