module Kiln

  class LockButton < UIButton
    States = 3
    UnlockedState = 0
    LockedVerticalState = 1
    LockedHorizontalState = 2

    UnlockedImage = 'kiln_lock_button_unlocked'.uiimage
    LockedHorizontalImage = 'kiln_lock_button_horizontal'.uiimage
    LockedVerticalImage = 'kiln_lock_button_vertical'.uiimage

    attr :lock_state

    def init
      frame = [[0, 0], UnlockedImage.size]
      initWithFrame(frame)
    end

    def initWithFrame(frame)
      super.tap do
        @lock_state = UnlockedState
        update_state
        self.on :touch do
          @lock_state += 1
          @lock_state = @lock_state % States
          update_state
        end
      end
    end

    def update_state
      case @lock_state
      when UnlockedState
        self.setImage(UnlockedImage, forState: :normal.uicontrolstate)
      when LockedVerticalState
        self.setImage(LockedVerticalImage, forState: :normal.uicontrolstate)
      when LockedHorizontalState
        self.setImage(LockedHorizontalImage, forState: :normal.uicontrolstate)
      end
    end

  end

end
