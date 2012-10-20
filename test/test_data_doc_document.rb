require_relative 'test_helper.rb'

describe DataDoc::Document do

  before do
    @doc = DataDoc::Document.new
  end

  after do
    output = StringIO.new
    @doc.output = output
    @doc.generate(@input)
    output.rewind
    output.read.chomp.must_match @expected_output
  end
      
  it "should process empty input" do
    @input = ""
    @expected_output = ""
  end
        
end
