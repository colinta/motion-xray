module Motion ; module Xray

  class XrayLockButton < UIButton
    States = 4
    LockedState = 0
    UnlockedState = 1
    LockedVerticalState = 2
    LockedHorizontalState = 3
    InitialState = LockedState

    UnlockedImage = 'xray_lock_button_unlocked'.uiimage
    LockedHorizontalImage = 'xray_lock_button_horizontal'.uiimage
    LockedVerticalImage = 'xray_lock_button_vertical'.uiimage
    LockedImage = 'xray_lock_button_locked'.uiimage

    attr :lock_state

    def init
      frame = [[0, 0], UnlockedImage.size]
      initWithFrame(frame)
    end

    def initWithFrame(frame)
      super.tap do
        @lock_state = InitialState
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
      when LockedState
        self.setImage(LockedImage, forState: :normal.uicontrolstate)
      end
    end

  end

end end
