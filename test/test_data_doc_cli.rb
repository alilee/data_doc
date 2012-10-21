require_relative 'test_helper.rb'
require_relative '../lib/data_doc/cli'
require 'tempfile'

describe DataDoc::CLI do
     
  before do
    @temp_files = Set.new
  end
  
  def temp_file(content)
    f = Tempfile.new('test_data_doc_cli') do |io|
      io.write(content)
    end
    @temp_files.add(f)
    f.path
  end
  
  after do
    @temp_files.each { |f| f.unlink }
    @temp_files.clear
  end  
    
  def execute_cli(*args) 
    DataDoc::CLI.execute(stdout_io = StringIO.new, args)
    stdout_io.rewind
    stdout_io.read.chomp
  end

  describe "with no file" do

    it "should present version" do
      execute_cli('--version').must_equal DataDoc::VERSION
    end

    it "should present help" do
      result = execute_cli('--help')
      result.must_match(/#{DataDoc::DESCRIPTION}/)
      result.must_match(/Usage:/)
      result.must_match(/--help/)
    end

  end
  
  describe "with a file" do
        
    describe "which is empty" do
      
      before do
        @filename = temp_file("")
      end
      
      it "should return" do
        execute_cli(@filename)
      end
  
      describe "with connection settings file" do
          
        before do
          @db_filename = temp_file("")
          connection_yaml = <<YAML
adapter: sqlite3
database: #{@db_filename}
YAML
          @connection_filename = temp_file(connection_yaml)
        end
        
        it "should accept a connection option" do
          filename = temp_file("")
          execute_cli("--connection", "#{@connection_filename}", filename).must_equal ""
        end
    
        it "should require a connection file" do
          proc { execute_cli('--connection') }.must_raise OptionParser::MissingArgument
        end
  
      end

      it "should accept a read-only option" do
        execute_cli("--read-only", @filename)
      end

      it "should accept a data-only option" do
        execute_cli("--data-only", @filename)
      end

      it "should accept an output file option" do
        output_filename = temp_file("")
        execute_cli("--output", output_filename, @filename)
      end

      it "should require a filename for output option" do
        proc { execute_cli("--output") }.must_raise OptionParser::MissingArgument
      end

      it "should accept a format option" do
        execute_cli("--format", 'html', @filename)
      end

      it "should require a format for format option" do
        proc { execute_cli("--format") }.must_raise OptionParser::MissingArgument
      end

      it "should require a valid format for format option" do
        proc { execute_cli("--format", 'invalid') }.must_raise OptionParser::InvalidArgument
      end

      it "should accept a verbose option" do
        execute_cli("--verbose", @filename)
      end
      
    end

  end
  
end