require_relative 'test_helper.rb'

describe DataDoc::Document do

  before do
    @doc = DataDoc::Document.new
  end

  after do
    output = StringIO.new
    @doc.output = output
    @doc.generate(StringIO.new(@input))
    output.rewind
    output.read.chomp.must_equal @expected_output
  end
      
  it "should process empty input" do
    @input = ""
    @expected_output = ""
  end
  
  it "should process markdown into html" do
    @input = '# Introduction'
    @expected_output = '<h1>Introduction</h1>'
  end
        
end
