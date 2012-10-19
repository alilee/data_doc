# require File.dirname(__FILE__) + '/test_helper.rb'
require_relative 'test_helper.rb'

describe DataDoc::Document do

  before do
    @doc = DataDoc::Document.new
  end
  
  it "should be instantiated" do
    @doc.wont_be_nil
  end
  
  it "should generate html for input" do
    input = ""
    result = @doc.generate_html(input)
    result.wont_be_nil
  end
  
end
