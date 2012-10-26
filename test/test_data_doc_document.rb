require_relative 'test_helper.rb'

describe DataDoc::Document do
    
  before do
    @doc = DataDoc::Document.new
    @input = ""
    @expected_output = ""
    @expected_rows = nil
    @expected_matches = Array.new
  end

  after do
    output_stream = StringIO.new
    @doc.output_stream = output_stream
    @doc.generate(StringIO.new(@input))
    output = output_stream.string
    output.strip.must_equal @expected_output.strip unless @expected_output.nil?
    @expected_matches.each do |m|
      if m.kind_of?(String)
        output.force_encoding("ASCII-8BIT").scan(m).first.must_equal(m)
      else
        output.must_match(m)
      end
    end
    unless @expected_rows.nil?
      @doc.connection.select_value("select count(1) from #{@expected_table_name}").must_equal(@expected_rows)
    end
  end
      
  it "should process empty input" do
    @input = ""
    @doc.layout = temp_file('<%= yield %>')
    @expected_output = ""
  end
  
  describe "for a simple document" do
    
    before do
      @input = '# Introduction'
      @doc.layout = temp_file('<%= yield %>')
    end
    
    it "should process markdown into html" do
      @expected_output = '<h1>Introduction</h1>'
    end
  
    it "should process markdown into pdf" do
      @expected_output = nil
      if system("prince 1> /dev/null 2> /dev/null")
        @doc.format = 'pdf'
        @expected_matches.push("%PDF")
        @doc.layout = temp_file('<%= yield %>')
      else
        skip "can't test pdf without prince"
      end
    end
  
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
      @expected_output = '<meta author="Author" />'
    end
  
    it "should insert script tags into the head" do
      @input = '<% script(src: "jquery.js") { "XXX" } %>'
      @doc.layout = temp_file('<%= yield :head %>')
      @expected_output = "<script src=\"jquery.js\">\nXXX\n</script>"
    end
  
    it "should insert link tags into the head" do
      @input = '<% link rel: "stylesheet", type: "text/css", href: "mystyle.css" %>'
      @doc.layout = temp_file('<%= yield :head %>')
      @expected_output = '<link rel="stylesheet" type="text/css" href="mystyle.css" />'
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
    
    it "should define stores" do
      @doc.connection = @conn_filename
      @doc.layout = temp_file('<%= yield %>')
      @input = "<% store 'relation' %>"
      @expected_output = ''
    end
    
    describe "adding rows" do
      
      before do
        @doc.connection = @conn_filename
        @doc.layout = temp_file('<%= yield %>')
        @expected_output = ''
        @expected_table_name = 'relation'
        @input = <<EOS
<% store 'relation' do
     string 'string'
   end
   relation string: 'a string'
%>      
EOS
      end
            
      it "should accept a row" do
        @expected_rows = 1
      end
      
      describe "when read_only" do

        before do
          @doc.connection.execute("create table relation(integer id, varchar string)")
          @doc.read_only = true
        end
        
        it "should ignore a row" do
          @expected_rows = 0          
        end
        
      end
      
    end
    
  end
  
  describe "presenting tables" do
    
    before do
      db_filename = temp_file("")
      conn_filename = temp_file("adapter: sqlite3\ndatabase: #{db_filename}") # YAML
      @doc.connection = conn_filename
      @doc.layout = temp_file('<%= yield %>')
      @doc.store 'relation' do
        string 'string'
        integer 'number'
      end
      @doc.relation(string: 'a string', number: 42)
    end
    
    it "should present raw sql" do
      @doc.present("select * from relation").must_match(/<table>.*<\/table>/) 
    end
    
    it "should present an arel" do
      table = @doc.present(@doc.relation.project('*'))
      table.must_match(/<table>.*<\/table>/)
    end

    it "should call a block for table configuration" do
      table = @doc.present(@doc.relation.project('*')) do
        caption 'Caption'
      end
      table.must_match(/<table>.*<\/table>/)
      table.must_match(/<caption>Caption<\/caption>/)
    end
    
  end

end
