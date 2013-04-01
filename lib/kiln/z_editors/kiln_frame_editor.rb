module Kiln

  class FrameEditor < PropertyEditor

    def edit_view(container_width)
      return UIView.alloc.initWithFrame([[0, 0], [container_width, 80]]).tap do |view|
        frame_view = UIView.alloc.initWithFrame([[4, 4], [92, 72]])
        frame_view.clipsToBounds = true
        frame_view.backgroundColor = :lightgray.uicolor
        frame_view.layer.borderWidth = 1
        frame_view.layer.borderColor = :gray.uicolor.cgcolor
        frame_view.layer.cornerRadius = 5
        view << frame_view

        labels_view = UIView.alloc.initWithFrame([[3, 0], [24, frame_view.bounds.height]])
        label = UILabel.new
        label.frame = [[4, 0], [18, 72]]
        label.text = "X:\nY:\nW:\nH:"
        label.textAlignment = :right.uitextalignment
        label.font = :small.uifont
        label.backgroundColor = :clear.uicolor
        label.numberOfLines = 4
        labels_view << label
        frame_view << labels_view

        values_view = UIView.alloc.initWithFrame([[labels_view.frame.max_x, 0], [65, frame_view.bounds.height]])
        values_view.backgroundColor = :white.uicolor
        values_view.layer.borderWidth = 1
        values_view.layer.borderColor = :gray.uicolor
        @frame_label = UILabel.new
        @frame_label.frame = [[8, 0], [52, 72]]
        @frame_label.font = :small.uifont
        @frame_label.backgroundColor = :clear.uicolor
        @frame_label.numberOfLines = 0
        values_view << @frame_label

        update_frame
        frame_view << values_view

        origin_dpad = KilnDpad.alloc.initWithFrame([[100, 4], [72, 72]])
        origin_dpad.add_listener(self, :change_origin)
        view << origin_dpad

        size_dpad = KilnDpad.alloc.initWithFrame([[176, 4], [72, 72]])
        size_dpad.add_listener(self, :change_size)
        view << size_dpad

        @locked_button = KilnLockButton.alloc.init
        @locked_button.frame = @locked_button.frame.x(252).y(27)
        view << @locked_button
      end
    end

    def update_frame
      frame = get_value
      @frame_label.text = "#{frame.origin.x}\n" +
        "#{frame.origin.y}\n" +
        "#{frame.size.width}\n" +
        "#{frame.size.height}"
    end

    def change_origin(delta)
      if @locked_button.lock_state == KilnLockButton::LockedState
        return
      end

      if @locked_button.lock_state == KilnLockButton::LockedHorizontalState
        delta.y = 0
      end
      if @locked_button.lock_state == KilnLockButton::LockedVerticalState
        delta.x = 0
      end

      frame = get_value
      frame.origin.x += delta.x
      frame.origin.y += delta.y
      set_value(frame)

      update_frame
    end

    def change_size(delta)
      if @locked_button.lock_state == KilnLockButton::LockedState
        return
      end

      if @locked_button.lock_state == KilnLockButton::LockedHorizontalState
        delta.y = 0
      end
      if @locked_button.lock_state == KilnLockButton::LockedVerticalState
        delta.x = 0
      end

      frame = get_value
      frame.size.width += delta.x
      frame.size.height += delta.y
      set_value(frame)

      update_frame
    end

    def did_change?
      ! CGRectEqualToRect(@original, @target.send(@property))
    end

  end

end
