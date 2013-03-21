module Kiln

  class KilnScrollView < UIScrollView

    def touchesShouldCancelInContentView(view)
      return false if view.is_a?(KilnDpad)
      return super
    end

  end

end
