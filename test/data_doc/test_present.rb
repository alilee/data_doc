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
  
  describe "generating a table" do
    
    before do
      @mock_doc.connection.execute("create table relation (one integer, two varchar)")
      @mock_doc.connection.insert_sql("insert into relation(one, two) values (1, 'one')")
      @mock_doc.connection.insert_sql("insert into relation(one, two) values (2, 'two')")
      @mock_doc.connection.insert_sql("insert into relation(one, two) values (3, 'three')")
    end
    
    describe "for a complex table" do
      
      before do
        @result = DataDoc::Present.present(@mock_doc, "select * from relation") do
          caption "Caption"
          label :one, "Renamed"
          column_order :two, :one, :three
          each_cell(:two) do |col, row|
            "two-changed"
          end
          calculated(:three) do |col, row|
            "column-three"
          end
        end
      end
    
      it "should accept a caption" do
        @result.must_match(/<caption>Caption<\/caption>/)
      end

      it "should rename a field label" do
        @result.must_match(/<th>Renamed<\/th>/)
      end

      it "should define the order of columns" do
        @result.must_match(/<th>Two<\/th><th>Renamed<\/th>/)
      end

      it "should allow a cell's contents to be programmed" do
        @result.must_match(/<td>two-changed<\/td>/)
      end

      it "should allow a calculation for a new column" do
        @result.must_match(/<td>column-three<\/td>/)
      end  
      
    end
    
    describe "for a table with headers" do
      before do
        @result = DataDoc::Present.present(@mock_doc, "select * from relation") do
          no_headers
        end
      end
    
      it "should suppress headers" do
        @result.wont_match(/<th>/)
      end
    end
    
    describe "with reformatting" do
      
      it "should accept an array of field names" do
        @result = DataDoc::Present.present(@mock_doc, "select * from relation") do
          each_cell ['one', 'two'] do |c,r|
            "reformatted #{c}"
          end
        end  
        @result.must_match(/reformatted one/)
        @result.must_match(/reformatted two/)
      end
      
      it "should allow reformatting reuse" do
        @result = DataDoc::Present.present(@mock_doc, "select * from relation") do
          each_cell 'one', 'two' do |c,r|
            "reformatted #{c}"
          end
        end  
        @result.must_match(/reformatted one/)
        @result.must_match(/reformatted two/)
      end
      
      it "should validate the field name" do
        proc { 
          DataDoc::Present.present(@mock_doc, "select * from relation") do
            each_cell 'four' do |c,r|
              "reformatted #{c}"
            end
          end
        }.must_raise(RuntimeError)
      end
            
    end
            
  end
  
end
    