require_relative 'test_helper.rb'

describe DataDoc::Store do
  
  before do
    @store = DataDoc::Store.new
  end
  
  it "should accept connection settings" do
    @db_filename = temp_file("")
    @store.connection = {adapter: 'sqlite3', database: @db_filename}
  end  
  
end
