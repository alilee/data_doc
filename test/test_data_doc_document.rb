require_relative 'test_helper.rb'

describe DataDoc::Document do
    
  before do
    @doc = DataDoc::Document.new
    @input = ""
    @expected_output = ""
  end

  after do
    output = StringIO.new
    @doc.output = output
    @doc.generate(StringIO.new(@input))
    output.rewind
    output.read.chomp.must_equal @expected_output.chomp
  end
      
  it "should process empty input" do
    @input = ""
    @doc.layout = temp_file('<%= yield %>')
    @expected_output = ""
  end
  
  it "should process markdown into html" do
    @input = '# Introduction'
    @doc.layout = temp_file('<%= yield %>')
    @expected_output = '<h1>Introduction</h1>'
  end
  
  it "should wrap the generated text in a layout" do
    layout_filename = temp_file('layout:<%= yield %>:layout')
    @input = "<% set_layout_file '#{layout_filename}' %>Some text."
    @expected_output = "layout:<p>Some text.</p>\n:layout"
  end
  
  it "should wrap the content in a default html layout" do
    @input = "<p>XXX</p>"
    @expected_output = erb(DataDoc::Document.default_layout) do
      @input + "\n"
    end    
  end
  
  # it "should insert meta tags into the head"
  # it "should insert script tags into the head"
  # it "should insert link tags into the head"
  # it "should set the html document title in the head"

end
