class UIImage
  class << self
    alias :imageNamed_xray_old :imageNamed
    def imageNamed(name)
      # this should log names and images, so we can refer to images by *name*
      imageNamed_xray_old(name)
    end
  end
end

class UIView

  class << self
    attr_accessor :xray

    def xray
      {
        'Frame' => {
          frame: Motion::Xray::FrameEditor,
        },
        'Color' => {
          backgroundColor: Motion::Xray::ColorEditor,
        },
        'UI' => {
          hidden: Motion::Xray::BooleanEditor,
          userInteractionEnabled: Motion::Xray::BooleanEditor,
          accessibilityLabel: Motion::Xray::TextEditor,
        },
      }
    end

    # this could be optimized a tiny bit by only calling superclass.build_xray
    # but i am le tired
    def build_xray
      @build_xray ||= begin
        retval = Hash.new { |hash,key| hash[key] = {} }
        klasses = []
        klass = self
        while klass && klass <= UIView
          klasses.unshift(klass)
          klass = klass.superclass
        end

        klasses.each do |klass|
          xray_props = klass.xray
          xray_props && xray_props.each do |key,values|
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

  def xray
    self.class.build_xray
  end

  def xray_subviews
    subviews
  end

end

class << UIWindow
  def xray
    {
      'TurnOff' => {
        frame: nil,
        hidden: nil,
        userInteractionEnabled: nil,
      },
    }
  end
end

class << UILabel
  def xray
    {
      'Content' => {
        text: Motion::Xray::TextEditor,
      }
    }
  end
end

class << UITabBar
  def xray
    {
      'Color' => {
        tintColor: Motion::Xray::ColorEditor,
      },
    }
  end
end

class << UINavigationBar
  def xray
    {
      'Color' => {
        tintColor: Motion::Xray::ColorEditor,
      },
    }
  end
end

class UIButton
  def xray_subviews
    []
  end
end

class UITableViewCell
  def xray_subviews
    contentView.subviews
  end
end
