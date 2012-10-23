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
    def initialize(doc, table_name_or_sym, opts = {}, &blk)
      @doc = doc
      @connection = @doc.connection
      create_store(table_name_or_sym, opts, &blk)
    end
    
    # AREL object encapsulating table.
    attr_reader :arel
            
    #
    # Define a string field.
    #
    def string(name, opts = {})
      @connection.add_column(@arel.name, name, :string, opts)
    end
    
    #
    # Define an integer field.
    #
    def integer(name, opts = {})
      @connection.add_column(@arel.name, name, :integer, opts)
    end
    
    # 
    # Define a text field.
    #
    def text(name, opts = {})
      @connection.add_column(@arel.name, name, :text, opts)
    end
    
    # 
    # Define a datetime field.
    #
    def datetime(name, opts = {})
      @connection.add_column(@arel.name, name, :datetime, opts)
    end    
    
    #
    # Insert a row from a hash. 
    #
    def insert(record)
      manager = @arel.insert_manager
      columns = record.keys.map { |k| @arel[k] }
      manager.insert(columns.zip(record.values))
      @connection.insert(manager)
    end

  protected
    
    #
    # Create and empty the store unless options prevent. 
    #
    def create_store(table_name_or_sym, opts = {}, &blk)
      table_name = table_name_or_sym.to_s 
      @arel = Arel::Table.new(table_name)
      unless @doc.read_only
        if @doc.data_only
          @connection.delete_sql("DELETE from #{table_name}")
        else
          @connection.create_table(table_name, opts.merge(force: true))
        end
      end
      self.instance_eval(&blk) if block_given?
      table_name_or_sym
    end
            
  end
  
end