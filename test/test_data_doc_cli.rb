require_relative 'test_helper.rb'
require_relative '../lib/data_doc/cli'

describe DataDoc::CLI do
       
  before do
    @filename = '/tmp/data_doc_test_file'
  end
  
  after do
    File.delete(@filename) if File.exists?(@filename)
  end
  
  def execute_cli(*args) 
    DataDoc::CLI.execute(@stdout_io = StringIO.new, args)
    @stdout_io.rewind
    @stdout_io.read.chomp
  end
  
  it "should present version" do
    execute_cli('--version').must_match DataDoc::VERSION
  end
  
  it "should process a file" do
    File.open(@filename, "w") do
    end
    execute_cli(@filename).must_match ""
  end
    
end