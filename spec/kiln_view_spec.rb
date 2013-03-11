class KilnViewSpec < UIView

  class << self
    def kiln
      @kiln = {
        'Content' => { text: Kiln::TextEditor }
      }
    end
  end

end


describe "Kiln view extensions" do
  before do
    @view_a = UIView.alloc.init
    @view_b = KilnViewSpec.alloc.init
  end

  it "should have kiln properties" do
    @view_a.kiln.should != nil
  end

  it "should have kiln properties that are a hash" do
    Hash.should === @view_a.kiln
  end

  it "should have kiln properties that are {section: {property: Editor}}" do
    first = @view_a.kiln.first
    String.should === first[0]
    Hash.should === first[1]
    first_editor = first[1].first
    Symbol.should === first_editor[0]
    Hash.should === first_editor[1]
  end

  it "should merge kiln properties" do
    @view_b.kiln.length.should > @view_a.kiln.length
    @view_b.kiln['Frame'].should == @view_a.kiln['Frame']
    @view_b.kiln['Content'].should == {text: Kiln::TextEditor}
  end

end
