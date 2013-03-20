module Kiln

  class TextEditor < PropertyEditor

    def edit_view(rect)
      canvas_bounds = CGRect.new([0, 0], [Kiln.ui.full_screen_width, Kiln.ui.half_screen_height])
      @text_editor_margin = 20
      @text_editor_modal = UIView.alloc.initWithFrame(Kiln.window.bounds).tap do |text_editor_modal|
        text_editor_modal.backgroundColor = :black.uicolor(0.5)

        close_editor_control = UIControl.alloc.initWithFrame(text_editor_modal.bounds)
        close_editor_control.on :touch do
          # touching outside
          self.close_text_editor
        end
        text_editor_modal << close_editor_control

        text_editor_modal << UIView.alloc.initWithFrame(canvas_bounds.shrink(@text_editor_margin)).tap do |background|
          background.layer.cornerRadius = 5
          background.layer.borderWidth = 1
          background.layer.borderColor = :dimgray.uicolor.cgcolor
          background.backgroundColor = :black.uicolor

          @text_editor = UITextView.alloc.initWithFrame(background.bounds.shrink(10))
          background << @text_editor
        end
      end
      @text_editor_modal.frame = @text_editor_modal.frame.right(Kiln.app_bounds.width)
      @text_editor_modal.fade_out

      return UIView.alloc.initWithFrame([[0, 0], [rect.width, 77]]).tap do |view|
        label_view = UILabel.new.style(
          frame: [[4, 5], [rect.width - 8, 18]],
          text: @property.to_s,
          font: :small,
          background: :clear,
          numberOfLines: 1,
        )
        view << label_view

        @open_text_button = UIButton.custom.tap do |button|
          button.setImage('kiln_icon_edit'.uiimage, forState: :normal.uicontrolstate)
          button.frame = view.bounds
          button.sizeToFit
          button.frame = button.frame.x(view.bounds.top_right.x - button.frame.width)
          button.on :touch {
            open_text_editor
          }
        end
        view << @open_text_button

        @text_view = UITextView.alloc.initWithFrame([[4, 23], [rect.width, 54]]).tap do |text_view|
          text_view.backgroundColor = :white.uicolor
          text_view.editable = false
          text_view.font = :small.uifont
          text_view.layer.borderWidth = 1
          text_view.layer.borderColor = :black.uicolor.cgcolor
        end
        view << @text_view
        update_text
      end

    end

    def update_text
      @text_view.text = get_value
    end

    def open_text_editor
      # move it off screen before sliding it in
      @text_editor.text = get_value
      Kiln.window << @text_editor_modal
      @text_editor.becomeFirstResponder
      @text_editor_modal.fade_in
      @text_editor_modal.slide(:left) {
        @open_text_button.userInteractionEnabled = true
      }
    end

    def close_text_editor
      @text_editor.resignFirstResponder
      update_text
      @text_editor_modal.fade_out
      @text_editor_modal.slide(:left) {
        @text_editor_modal.removeFromSuperview
        # move it off screen, ready to move back in
        @text_editor_modal.frame = @text_editor_modal.frame.x(Kiln.app_bounds.width)
        @open_text_button.userInteractionEnabled = true
        set_value(@text_editor.text)
      }
    end

  end

end
