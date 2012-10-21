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
    output.read.strip.must_equal @expected_output.strip
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
  
  describe "layout" do

    it "should wrap the generated text in a layout" do
      layout_filename = temp_file('layout:<%= yield %>:layout')
      @input = "<% set_layout_file '#{layout_filename}' %>Some text."
      @expected_output = "layout:<p>Some text.</p>\n:layout"
    end
  
    it "should wrap the content in a default html layout" do
      @input = "<p>XXX</p>"
      @expected_output = erb(DataDoc::Document.default_layout) do |section|
        @input + "\n" if section.to_s != 'head'
      end    
    end
    
  end
  
  describe "head tags" do
  
    it "should insert meta tags into the head" do
      @input = '<% meta author: "Author" %>'
      @doc.layout = temp_file('<%= yield :head %>')
      @expected_output = '<meta author="Author">'
    end
  
    it "should insert script tags into the head" do
      @input = '<% script(src: "jquery.js") { "XXX" } %>'
      @doc.layout = temp_file('<%= yield :head %>')
      @expected_output = "<script src=\"jquery.js\">\nXXX\n</script>"
    end
  
    it "should insert link tags into the head" do
      @input = '<% link rel: "stylesheet", type: "text/css", href: "mystyle.css" %>'
      @doc.layout = temp_file('<%= yield :head %>')
      @expected_output = '<link rel="stylesheet" type="text/css" href="mystyle.css">'
    end
  
    it "should set the html document title in the head and in a div.title in the content" do
      @input = '<%= title "Title" %>'
      @doc.layout = temp_file('Head:<%= yield :head %>Content:<%= yield %>')
      @expected_output = 'Head:<title>Title</title>Content:<div class="title">Title</div>'
    end
  
  end
  
  describe "defining stores" do
    
    before do
      @db_filename = temp_file("")
      @conn_filename = temp_file("adapter: sqlite3\ndatabase: #{@db_filename}") # YAML
    end
    
    it "should specify connection settings to a database via DSL" do
      @input = "<% set_connection adapter: 'sqlite3', database: '#{@db_filename}' %>"
      @doc.layout = temp_file('')
      @expected_output = ''
    end
    
    it "should accept connection settings via option" do
      @doc.connection = @conn_filename
      @doc.layout = temp_file('<%= yield %>')
      @input = ''
      @expected_output = ''
    end
    
  end
  

end
