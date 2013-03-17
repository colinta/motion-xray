module Kiln
  module_function

  def ui
    @kiln ||= UI.new
  end

  def toggle
    Kiln.ui.toggle
  end

  def fire_up
    Kiln.ui.fire_up
  end

  def cool_down
    Kiln.ui.cool_down
  end

end
