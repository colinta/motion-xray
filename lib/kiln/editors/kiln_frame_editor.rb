module Kiln

  class FrameEditor < PropertyEditor

    def edit_view(rect)
      return UIView.alloc.initWithFrame([[0, 0], [rect.width, 80]]).tap do |view|
        frame_view = UIView.alloc.initWithFrame([[4, 4], [92, 72]])
        frame_view.style(
          clips: true,
          background: :lightgray,
          layer: {
            borderWidth: 1,
            borderColor: :gray,
            cornerRadius: 5
          })
        view << frame_view

        labels_view = UIView.alloc.initWithFrame([[3, 0], [24, frame_view.bounds.height]])
        labels_view << UILabel.new.style(
          frame: [[4, 0], [18, 72]],
          text: "X:\nY:\nW:\nH:",
          alignment: :right,
          font: :small,
          background: :clear,
          numberOfLines: 4,
        )
        frame_view << labels_view

        values_view = UIView.alloc.initWithFrame([[labels_view.frame.max_x, 0], [65, frame_view.bounds.height]])
        values_view.style(
          background: :white,
          layer: {
            borderWidth: 1,
            borderColor: :gray,
          })
        values_view << (@frame_label = UILabel.new.style(
          frame: [[8, 0], [52, 72]],
          font: :small,
          background: :clear,
          numberOfLines: 0,
        ))
        update_frame
        frame_view << values_view

        origin_dpad = DPad.alloc.initWithFrame([[100, 4], [72, 72]])
        origin_dpad.add_listener(self, :change_origin)
        view << origin_dpad

        size_dpad = DPad.alloc.initWithFrame([[176, 4], [72, 72]])
        size_dpad.add_listener(self, :change_size)
        view << size_dpad

        @locked_button = LockButton.alloc.init
        @locked_button.style(origin: [252, 27])
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
      if @locked_button.lock_state == LockButton::LockedState
        return
      end

      if @locked_button.lock_state == LockButton::LockedHorizontalState
        delta.y = 0
      end
      if @locked_button.lock_state == LockButton::LockedVerticalState
        delta.x = 0
      end

      frame = get_value
      frame.origin.x += delta.x
      frame.origin.y += delta.y
      set_value(frame)

      update_frame
    end

    def change_size(delta)
      if @locked_button.lock_state == LockButton::LockedState
        return
      end

      if @locked_button.lock_state == LockButton::LockedHorizontalState
        delta.y = 0
      end
      if @locked_button.lock_state == LockButton::LockedVerticalState
        delta.x = 0
      end

      frame = get_value
      frame.size.width += delta.x
      frame.size.height += delta.y
      set_value(frame)

      update_frame
    end

  end

end
