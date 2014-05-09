module Motion ; module Xray

  class ColorEditor < PropertyEditor
    ColorEditorMargin = 20

    def edit_view(container_width)
      canvas_bounds = Xray.layout.bottom_half.frame
      @color_editor_modal = UIView.alloc.initWithFrame(Xray.window.bounds).tap do |color_editor_modal|
        close_editor_control = UIControl.alloc.initWithFrame(color_editor_modal.bounds)
        close_editor_control.on :touch do
          # touching outside
          self.close_color_editor
        end
        color_editor_modal << close_editor_control

        toolbar = XrayToolbar.alloc.initWithFrame(canvas_bounds.shrink(ColorEditorMargin).height(25).up(25))
        toolbar.layer.cornerRadius = 3
        color_editor_modal << toolbar
        background = UIView.alloc.initWithFrame(canvas_bounds.shrink(ColorEditorMargin)).tap do |background|
          background.layer.cornerRadius = 5
          background.layer.borderWidth = 1
          background.layer.borderColor = :dimgray.uicolor.cgcolor
          background.backgroundColor = :black.uicolor
        end
        color_editor_modal << background

        @color_names = UIScrollView.alloc.initWithFrame(background.bounds.shrink(10)).tap do |scroll|
          typewriter = XrayTypewriterView.alloc.initWithFrame([[0, 0], scroll.frame.size])
          typewriter.centered = true
          typewriter.scroll_view = scroll
          typewriter.spacing = [2, 2]
          typewriter.margin = [2, 2, 2, 2]
          typewriter.backgroundColor = :black.uicolor
          Symbol.css_colors.each do |css_name, color|
            button = UIButton.rounded
            button.tintColor = color.uicolor
            button.setTitle(css_name, forState: :normal.uicontrolstate)
            button.setTitleColor(color.uicolor, forState: :normal.uicontrolstate)
            button.sizeToFit
            button.on :touch {
              color = css_name.uicolor
              color_did_change(color)
              @color_sliders.color = color
            }
            typewriter << button
          end
          scroll << typewriter
        end

        @color_sliders = XrayColorSliders.alloc.initWithFrame(background.bounds.shrink(10))
        @color_sliders.on :change {
          color_did_change(@color_sliders.color)
        }

        toolbar.canvas = background
        toolbar.add('RGB', @color_sliders)
        toolbar.add('Named', @color_names)
      end
      @color_editor_modal.frame = @color_editor_modal.frame.right(Xray.app_bounds.width)
      @color_editor_modal.fade_out

      return UIView.alloc.initWithFrame([[0, 0], [container_width, 34]]).tap do |view|
        color_size = CGSize.new(50, 24)
        @color_picker = XrayColorSwatch.alloc.initWithFrame([[4, 4], color_size])
        @color_picker.color = get_value
        view << @color_picker

        @color_picker.on :touch do
          open_color_editor
        end

        label_x = color_size.width + 8
        @label_view = UILabel.new.tap do |lbl|
          lbl.frame = [[label_x, 5], [container_width - label_x, 18]]
          lbl.font = :small.uifont
          lbl.backgroundColor = :clear.uicolor
          lbl.numberOfLines = 1
        end
        view << @label_view
        update_views
      end
    end

    def open_color_editor
      @color_picker.userInteractionEnabled = false
      # move it off screen before sliding it in
      Xray.window << @color_editor_modal
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
        @color_editor_modal.frame = @color_editor_modal.frame.x(Xray.app_bounds.width)
        @color_picker.userInteractionEnabled = true
      }
    end

    def update_views
      color = get_value
      @color_picker.color = color
      @label_view.text = "#{@property}: #{color.inspect}"
    end

    def color_did_change(color)
      set_value(color)
      update_views
    end

  end

end end
