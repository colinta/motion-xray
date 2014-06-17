# @requires Motion::Xray
module Motion::Xray

  class BooleanEditor < PropertyEditor

    def edit_view(container_width)
      return UIView.alloc.initWithFrame([[0, 0], [container_width, 27]]).tap do |view|
        view << UILabel.alloc.initWithFrame([[0, 4.5], view.bounds.size]).tap do |lbl|
          lbl.backgroundColor = :clear.uicolor
          lbl.text = "#{@property}?"
          lbl.font = :small.uifont
        end
        view << UISwitch.alloc.init.tap do |switch|
          switch.frame = switch.frame.x(view.bounds.max_x - switch.frame.width)
          switch.on = !!get_value
          switch.on(:change) {
            set_value(switch.on?)
          }
        end
      end
    end

  end

end
