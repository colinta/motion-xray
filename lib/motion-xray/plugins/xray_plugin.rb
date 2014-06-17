# @provides Motion::Xray::Plugin
# @requires Motion::Xray
module Motion::Xray

  class Plugin
    attr :name
    attr :icon

    def self.name(value=nil)
      if value
        @name = value
      else
        @name
      end
    end

    def self.icon(value=nil)
      if value
        @icon = value
      else
        @icon
      end
    end

    def initialize
      if self.class.name
        @name = self.class.name
      else
        @name = default_name
      end

      if self.class.icon
        @icon = self.class.icon && self.class.icon.uiimage
      else
        @icon = default_icon
      end
    end

    def default_name
      self.class.to_s.sub(/Plugin$/, '').sub(/^Motion::Xray::/, '')
    end

    def default_icon
      'xray/default_plugin'.uiimage
    end

  end

end
