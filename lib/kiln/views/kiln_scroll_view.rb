module Kiln

  class KilnScrollView < UIScrollView

    def touchesShouldCancelInContentView(view)
      return false if view.is_a?(DPad)
      return super
    end

  end

end
