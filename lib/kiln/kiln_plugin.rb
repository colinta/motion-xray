module Kiln

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

    def kiln_name
      @name || self.class.name
    end

    def kiln_view_in(canvas)
      raise "You must implement `#{self.class}#kiln_view_in`"
    end

    def get_kiln_view_in(canvas)
      @view = kiln_view_in(canvas)
    end

    def kiln_edit(target)
      @target = target
    end

    def show
    end

    def hide
    end

  end

end
