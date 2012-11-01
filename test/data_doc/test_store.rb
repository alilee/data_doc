require_relative '../test_helper.rb'

describe DataDoc::Store do
    
  before do
    @mock_doc = MockDoc.new
  end
    
  describe "defining stores" do

    describe "create table" do

      before do
        @mock_doc.connection.create_table('relation', force: true)
        @mock_doc.connection.add_column('relation', 'string', :string, default: 'present')
        @mock_doc.connection.insert_sql('INSERT INTO relation(id) VALUES (1)')
        @confirm_old_table_value = false
        @confirm_old_table_column = false
      end

      after do
        DataDoc::Store.store(@mock_doc, 'relation')
        @mock_doc.connection.select_value('select count(1) from relation').must_equal @expected_rows
        if @confirm_old_table_value
          @mock_doc.connection.select_value('select string from relation limit 1').must_equal 'present'
        end
        if @confirm_old_table_column
          @mock_doc.connection.insert_sql("INSERT INTO relation(string) VALUES ('hello')")
        end
      end

      it "shouldn't create a table if read_only" do
        @mock_doc.read_only = true
        @expected_rows = 1
        @confirm_old_table_value = true
      end

      it "shouldn't create a table if data_only" do
        @mock_doc.data_only = true
        @expected_rows = 0
        @confirm_old_table_column = true
      end

      it "should truncate the table if data_only" do
        @mock_doc.data_only = true
        @expected_rows = 0
      end
          
      it "shouldn't truncate the table if read_only" do
        @mock_doc.read_only = true
        @expected_rows = 1
        @confirm_old_table_value = true
      end
          
    end
        
    describe "add attributes" do
                    
      def check_insert(field, value)
        @mock_doc.connection.select_value("insert into relation(#{field}) values ('#{value}')").must_be_nil
      end
          
      it "adds a string attribute" do
        DataDoc::Store.store(@mock_doc, 'relation') do
          string 'string'
        end
        check_insert('string', 'a string')
      end
          
      it "adds an integer attribute" do
        DataDoc::Store.store(@mock_doc, 'relation') do
          integer 'number'
        end
        check_insert('number', 42)
      end
          
      it "adds a text attribute" do
        DataDoc::Store.store(@mock_doc, 'relation') do
          text 'description'
        end
        check_insert('description', 'a string')            
      end
          
      it "adds a datetime attribute" do
        DataDoc::Store.store(@mock_doc, 'relation') do
          datetime 'timestamp'
        end
        check_insert('timestamp', '2012-10-12')
      end

      it "adds a date attribute" do
        DataDoc::Store.store(@mock_doc, 'relation') do
          date 'datestamp'
        end
        check_insert('datestamp', Date.today)
      end

      it "adds a time attribute" do
        DataDoc::Store.store(@mock_doc, 'relation') do
          time 'timestamp'
        end
        check_insert('timestamp', Time.now)
      end

      it "adds a float attribute" do
        DataDoc::Store.store(@mock_doc, 'relation') do
          float 'value'
        end
        check_insert('value', 42.234)
      end

      it "adds a boolean attribute" do
        DataDoc::Store.store(@mock_doc, 'relation') do
          boolean 'flag'
        end
        check_insert('flag', true)
      end
    end

    describe "alternate keys" do
    end
        
  end

  describe "accepting rows" do
          
    before do
      @store = DataDoc::Store.store(@mock_doc, 'relation') do
        string 's'
        integer 'i'
        text 't'
      end    
      @mock_doc.connection.select_value("select count(1) from relation").must_equal 0
    end
    
    describe "when not read_only" do
    
      after do
        @mock_doc.connection.select_value("select count(1) from relation").must_equal 1
      end
      
      it "should accept a row" do
        @store.insert(s: 'a string', i: 42, t: 'a string')
      end

    end
    
    describe "when read_only" do

      before do
        @mock_doc.read_only = true
      end

      after do
        @mock_doc.connection.select_value("select count(1) from relation").must_equal 0
      end
      
      it "should ignore a row" do
        @store.insert(s: 'a string', i: 42, t: 'a string')
      end
      
    end
    
  end

end