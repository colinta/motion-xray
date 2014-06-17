# @requires Motion::Xray
module Motion::Xray

  class ImageEditor < PropertyEditor

    def edit_view(container_width)
      canvas_bounds = Motion::Xray.layout.bottom_half.frame
      @editor_margin = 20
      @editor_modal = UIView.alloc.initWithFrame(Motion::Xray.window.bounds).tap do |editor_modal|
        close_editor_control = UIControl.alloc.initWithFrame(editor_modal.bounds)
        close_editor_control.on :touch do
          # touching outside
          self.close_editor
        end
        editor_modal << close_editor_control

        editor_modal << UIView.alloc.initWithFrame(canvas_bounds.shrink(@editor_margin)).tap do |background|
          background.layer.cornerRadius = 5
          background.layer.borderWidth = 1
          background.layer.borderColor = :dimgray.uicolor.cgcolor
          background.backgroundColor = :black.uicolor

          @image_picker = ImagePicker.alloc.initWithFrame(background.bounds.shrink(10))
          background << @image_picker
          @image_picker.on :change {
            image_did_change(@image_picker.image)
          }
        end
      end
      @editor_modal.frame = @editor_modal.frame.right(Motion::Xray.app_bounds.width)
      @editor_modal.fade_out

      return UIView.alloc.initWithFrame([[0, 0], [container_width, 34]]).tap do |view|
        image_size = CGSize.new(50, 24)
        @image_thumbnail = XrayColorSwatch.alloc.initWithFrame([[4, 4], image_size])
        @image_thumbnail.image = get_value
        view << @image_thumbnail

        @image_thumbnail.on :touch do
          open_editor
        end

        label_x = image_size.width + 8
        label_view = UILabel.new
        label_view.frame = [[label_x, 5], [container_width - label_x, 18]]
        label_view.text = @property.to_s
        label_view.font = :small.uifont
        label_view.backgroundColor = :clear.uicolor
        label_view.numberOfLines = 1
        view << label_view
      end
    end

    def open_editor
      @image_thumbnail.userInteractionEnabled = false
      # move it off screen before sliding it in
      Motion::Xray.window << @editor_modal
      @image_picker.image = get_value
      @editor_modal.fade_in
      @editor_modal.slide(:left) {
        @image_thumbnail.userInteractionEnabled = true
      }
    end

    def close_editor
      @image_thumbnail.userInteractionEnabled = false
      @editor_modal.fade_out
      @editor_modal.slide(:left) {
        @editor_modal.removeFromSuperview
        # move it off screen, ready to move back in
        @editor_modal.frame = @editor_modal.frame.x(Motion::Xray.app_bounds.width)
        @image_thumbnail.userInteractionEnabled = true
      }
    end


  end

end
