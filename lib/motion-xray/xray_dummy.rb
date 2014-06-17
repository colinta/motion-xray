# @requires Motion::Xray
module Motion::Xray
  module_function
  def dummy
    view.userInteractionEnabled = true
    view.userInteractionEnabled?
    view.isUserInteractionEnabled
  end
end
