module Kiln

  class PersistUIPlugin < Plugin
    name 'Save UI'

    def initialize
      # uiview instance => list of changes
      @changes = {}
    end

    def kiln_view_in(canvas)
    end

    def kiln_edit(target)
      super
    end

  end

end

