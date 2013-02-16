class HeaderBackground < UIView
  attr_accessor :label

  def initWithFrame(frame)
    super.tap do
      self.layer.borderWidth = 1
      self.layer.borderColor = :kiln_dashboard_label_border.uicolor.CGColor
      self.layer.backgroundColor = :kiln_dashboard_label_bg.uicolor.CGColor
    end
  end

  def label=(lbl)
    if @label
      @label.removeFromSuperview
    end
    @label = lbl
    self << @label
  end

  def text=(str)
    label.text = str
  end

end

class HeaderLabel < UILabel

  def initWithFrame(frame)
    super.tap do
      self.font = 'Futura'.uifont(12)
      self.textAlignment = :left.uitextalignment
      self.textColor = :kiln_dashboard_label_text.uicolor
      self.backgroundColor = :clear.uicolor
    end
  end

end
