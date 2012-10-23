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
    #   store
    #
    #
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