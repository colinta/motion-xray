class UIImage
  class << self
    alias :imageNamed_kiln_old :imageNamed
    def imageNamed(name)
      imageNamed_kiln_old(name)
    end
  end
end

class UIView

  class << self
    attr_accessor :kiln

    def kiln
      @kiln ||= {
        'Frame' => {
          frame: Kiln::FrameEditor,
        },
        'Color' => {
          backgroundColor: Kiln::ColorEditor,
        },
        'UI' => {
          hidden: Kiln::BooleanEditor,
          userInteractionEnabled: Kiln::BooleanEditor,
          accessibilityLabel: Kiln::TextEditor,
        },
      }
    end

    # this could be optimized a tiny bit by only calling superclass.build_kiln
    # but i am le tired
    def build_kiln
      @build_kiln ||= begin
        retval = Hash.new { |hash,key| hash[key] = {} }
        klasses = []
        klass = self
        while klass && klass <= UIView
          klasses.unshift(klass)
          klass = klass.superclass
        end

        klasses.each do |klass|
          kiln_props = klass.kiln
          kiln_props && kiln_props.each do |key,values|
            values.keys.each do |check_unique|
              retval.each do |section, editors|
                editors.delete(check_unique)
              end
            end
            retval[key].merge!(values)
          end
        end

        # clean out nil-editors and empty sections
        retval.each do |section, editors|
          editors.each do |property, editor|
            editors.delete(property) unless editor
          end
          retval.delete(section) if editors.length == 0
        end

        retval
      end
    end

  end

  def kiln
    self.class.build_kiln
  end

  def kiln_subviews
    subviews
  end

end

class << UIWindow
  def kiln
    @kiln ||= {
      'TurnOff' => {
        hidden: nil,
        userInteractionEnabled: nil,
      },
    }
  end
end

class << UILabel
  def kiln
    @kiln ||= {
      'Content' => {
        text: Kiln::TextEditor,
      }
    }
  end
end

class << UITabBar
  def kiln
    @kiln ||= {
      'Color' => {
        tintColor: Kiln::ColorEditor,
      },
    }
  end
end

class << UINavigationBar
  def kiln
    @kiln ||= {
      'Color' => {
        tintColor: Kiln::ColorEditor,
      },
    }
  end
end

class UIButton
  def kiln_subviews
    []
  end
end
