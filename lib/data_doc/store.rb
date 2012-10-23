require 'active_record'

module DataDoc

  #
  # Defines schema for structured content and accepts rows.
  #
  # Sets up an ActiveRecord store, defines its tables and 
  # fields, and adds row content.
  #
  class Store
    
    #
    # Define a store.
    #
    # Yields to a block calling the store for fields and other
    # schema definition. Table is re-created and emptied unless 
    # read_only, and just emptied if data_only.
    #
    def self.store(doc, table_name_or_sym, opts = {}, &blk) # :yields:
      s = Store.new(doc)
      s.create_store(table_name_or_sym, opts)
      s.instance_eval(&blk) unless blk.nil?
      s
    end
    
    # AREL object encapsulating table.
    attr_reader :arel
            
    #
    # Define a string field.
    #
    #   store 'relation' do
    #     string 'field_name', default: 'value'
    #     string :another_field, null: false
    #   end
    #
    def string(name, opts = {})
      @connection.add_column(@arel.name, name, :string, opts)
    end
    
    #
    # Define an integer field.
    #
    #   store 'relation' do
    #     integer 'field_name', default: 42
    #     integer :another_field
    #   end
    #
    def integer(name, opts = {})
      @connection.add_column(@arel.name, name, :integer, opts)
    end
    
    # 
    # Define a text field.
    #
    #   store 'relation' do
    #     text 'field_name'
    #     text :another_field
    #   end
    #
    def text(name, opts = {})
      @connection.add_column(@arel.name, name, :text, opts)
    end
    
    # 
    # Define a datetime field.
    #
    #   store 'relation' do
    #     datetime 'field_name'
    #     datetime :another_field
    #   end
    #
    def datetime(name, opts = {})
      @connection.add_column(@arel.name, name, :datetime, opts)
    end    
    
    
    # 
    # Define a datetime field.
    #
    #   store 'relation' do
    #     time 'field_name'
    #     time :another_field
    #   end
    #
    def time(name, opts = {})
      @connection.add_column(@arel.name, name, :time, opts)
    end
    
    # 
    # Define a date field.
    #
    #   store 'relation' do
    #     date 'field_name'
    #     date :another_field
    #   end
    #
    def date(name, opts = {})
      @connection.add_column(@arel.name, name, :date, opts)
    end
    
    # 
    # Define a boolean field.
    #
    #   store 'relation' do
    #     boolean 'field_name'
    #     boolean :another_field
    #   end
    #
    def boolean(name, opts = {})
      @connection.add_column(@arel.name, name, :boolean, opts)
    end
    
    # 
    # Define a float field.
    #
    #   store 'relation' do
    #     float 'field_name'
    #     float :another_field
    #   end
    #
    def float(name, opts = {})
      @connection.add_column(@arel.name, name, :float, opts)
    end   
  
    #
    # Insert a row from a hash. 
    #
    def insert(record)
      return if @doc.read_only
      manager = @arel.insert_manager
      columns = record.keys.map { |k| @arel[k] }
      manager.insert(columns.zip(record.values))
      @connection.insert(manager)
    end
    
    #
    # Create and empty the store unless options prevent. 
    #
    def create_store(table_name_or_sym, opts = {})
      table_name = table_name_or_sym.to_s 
      @arel = Arel::Table.new(table_name)
      unless @doc.read_only
        if @doc.data_only
          @connection.delete_sql("DELETE from #{table_name}")
        else
          @connection.create_table(table_name, opts.merge(force: true))
        end
      end
    end
    
    def initialize(doc)
      @doc = doc
      @connection = @doc.connection
    end
    
            
  end
  
end