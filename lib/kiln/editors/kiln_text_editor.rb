module Kiln

  class TextEditor < PropertyEditor

    def edit_view(rect)
      UIView.alloc.initWithFrame([[0, 0], [rect.width, 77]]).tap do |view|
        label_view = UILabel.new.style(
          frame: [[4, 5], [rect.width - 8, 18]],
          text: @property.to_s,
          font: :small,
          background: :clear,
          numberOfLines: 1,
        )
        view << label_view

        view << UIButton.custom.tap do |button|
          button.setImage('kiln_icon_edit'.uiimage, forState: :normal.uicontrolstate)
          button.frame = view.bounds
          button.sizeToFit
          button.frame = button.frame.x(view.bounds.top_right.x - button.frame.width)
          button.on :touch {
            #
          }
        end

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

  end

end
