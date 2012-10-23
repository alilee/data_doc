require_relative 'test_helper.rb'

describe DataDoc::Present do
    
  before do
    @mock_doc = MockDoc.new
  end
  
  it "should be" do
    DataDoc::Present.present(@mock_doc, "select 1")
  end
  
  it "should generate a table" do
    DataDoc::Present.present(@mock_doc, "select 1").must_match(/<table>.*<\/table>/)
  end
  
end
    