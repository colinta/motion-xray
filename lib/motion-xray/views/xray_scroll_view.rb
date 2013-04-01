module Motion ; module Xray

  class XrayScrollView < UIScrollView

    def touchesShouldCancelInContentView(view)
      return false if view.is_a?(XrayDpad)
      return super
    end

  end

end end
