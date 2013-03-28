module Kiln
  module_function
  def dummy
    view.userInteractionEnabled = true
    view.userInteractionEnabled?
    view.isUserInteractionEnabled
  end
end
