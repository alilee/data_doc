require_relative 'test_helper.rb'
require_relative '../lib/data_doc/cli'

describe DataDoc::CLI do
       
  def execute_cli(*args) 
    DataDoc::CLI.execute(@stdout_io = StringIO.new, args)
    @stdout_io.rewind
    @stdout_io.read.chomp
  end
  
  it "should present version" do
    execute_cli('--version').must_match DataDoc::VERSION
  end
  
end