# require File.dirname(__FILE__) + '/test_helper.rb'
require_relative 'test_helper.rb'

describe DataDoc do
  
  describe "integration tests" do
    
    before do
      @doc = DataDoc::Document.new
    end
    
    after do
      result = @doc.generate_html(@input)
      result.must_equal @expected_result  
    end  
    
    it "should process an empty doc" do
      @input = ""
      @expected_result = ""
    end
        
  end
  
end
