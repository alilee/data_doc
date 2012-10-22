require_relative 'test_helper.rb'

describe DataDoc::Store do
  
  class MockDoc

    attr_accessor :data_only, :read_only

    def initialize
      @data_only = false
      @read_only = false
    end

  end

  describe 'with new Store' do

    before do
      @mock_doc = MockDoc.new
      @store = DataDoc::Store.new(@mock_doc)
    end
    
    it "should accept connection settings" do
      db_filename = temp_file('')
      @store.connection = {adapter: 'sqlite3', database: db_filename}
    end  

    describe "with connection" do
      
      before do
        db_filename = temp_file('')
        @store.connection = {adapter: 'sqlite3', database: db_filename}
      end

      describe "defining stores" do

        describe "create table" do

          before do
            @store.connection.create_table('relation', force: true)
            @store.connection.add_column('relation', 'string', :string, default: 'present')
            @store.connection.insert_sql('INSERT INTO relation(id) VALUES (1)')
            @confirm_old_table_value = false
            @confirm_old_table_column = false
          end

          after do
            @store.store('relation')
            @store.connection.select_value('select count(1) from relation').must_equal @expected_rows
            if @confirm_old_table_value
              @store.connection.select_value('select string from relation limit 1').must_equal 'present'
            end
            if @confirm_old_table_column
              @store.connection.insert_sql("INSERT INTO relation(string) VALUES ('hello')")
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
            @store.connection.select_value("insert into relation(#{field}) values ('#{value}')").must_be_nil
          end
          
          it "adds a string attribute" do
            @store.store('relation') do
              string 'string'
            end
            check_insert('string', 'a string')
          end
          
          it "adds an integer attribute" do
            @store.store('relation') do
              integer 'number'
            end
            check_insert('number', 42)
          end
          
          it "adds a text attribute" do
            @store.store('relation') do
              text 'description'
            end
            check_insert('description', 'a string')            
          end
          
          it "adds a datetime attribute" do
            @store.store('relation') do
              datetime 'timestamp'
            end
            check_insert('timestamp', '2012-10-12')
          end

        end

        describe "alternate keys" do
        end
        
      end

      describe "accepting rows" do
      
        before do
          @store.store('relation') do
            string 's'
            integer 'i'
            text 't'
          end    
          @store.connection.select_value("select count(1) from relation").must_equal 0
        end
    
        after do
          @store.connection.select_value("select count(1) from relation").must_equal 1
        end
      
        it "should accept a row" do
          @store.relation(s: 'a string', i: 42, t: 'a string')
        end
      
      end
    
    end
    
  end
    
end
