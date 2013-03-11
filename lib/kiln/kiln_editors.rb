module Kiln
  class Editor
    include Teacup::Layout

    attr_accessor :property

    class << self
      def with_property(property)
        self.new(property)
      end
    end

    def initialize(property)
      @property = property
    end

    def get_edit_view(target, rect)
      @collapsible_view ||= self.edit_view(target, rect)
    end

  end

  class FrameEditor < Editor

    def edit_view(target, rect)
      UIView.alloc.initWithFrame([[0, 0], [rect.width, 30]]).tap { |view|
        position = UIView.alloc.initWithFrame([[0, 0], [rect.width / 2, 30]])
        position << UILabel.new.tap { |position_lbl|
          position_lbl.text = "X: #{target.frame.origin.x} Y: #{target.frame.origin.y}"
          position_lbl.font = :small.uifont
          position_lbl.backgroundColor = :clear.uicolor
          position_lbl.sizeToFit
          position_lbl.frame = position_lbl.frame.x(0).y(0)
        }
        view << position

        size = UIView.alloc.initWithFrame([[rect.width / 2, 0], [rect.width / 2, 30]])
        size << UILabel.new.tap { |size_lbl|
          size_lbl.text = "W: #{target.frame.size.width} H: #{target.frame.size.height}"
          size_lbl.font = :small.uifont
          size_lbl.backgroundColor = :clear.uicolor
          size_lbl.sizeToFit
          size_lbl.frame = size_lbl.frame.x(0).y(0)
        }
        view << size
      }
    end

  end


  class TextEditor < Editor
  end

end
