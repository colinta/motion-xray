module Motion ; module Xray

  class Plugin
    attr_accessor :name
    attr :view
    attr :target

    def Plugin.name(value=nil)
      if value
        @name = value
      else
        @name
      end
    end

    def xray_name
      @name || self.class.name
    end

    def plugin_view(canvas)
      raise "You must implement `#{self.class}#plugin_view`"
    end

    def get_plugin_view(canvas)
      @view ||= plugin_view(canvas)
    end

    def edit(target)
      @target = target
    end

    def show
    end

    def hide
    end

  end

end end
