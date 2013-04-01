class XrayViewSpec < UIView

  class << self
    def xray
      {
        'Content' => { text: Motion::Xray::TextEditor }
      }
    end
  end

end


describe "Xray view extensions" do
  before do
    @view_a = UIView.alloc.init
    @view_b = XrayViewSpec.alloc.init
  end

  it "should have xray properties" do
    @view_a.xray.should != nil
  end

  it "should have xray properties that are a hash" do
    Hash.should === @view_a.xray
  end

  it "should have xray properties that are {section: {property: Editor}}" do
    first = @view_a.xray.first
    String.should === first[0]
    Hash.should === first[1]
    first_editor = first[1].first
    Symbol.should === first_editor[0]
    Hash.should === first_editor[1]
  end

  it "should merge xray properties" do
    @view_b.xray.length.should > @view_a.xray.length
    @view_b.xray['Frame'].should == @view_a.xray['Frame']
    @view_b.xray['Content'].should == {text: Motion::Xray::TextEditor}
  end

end
