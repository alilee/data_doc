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
    # Create new.
    #
    def initialize(doc)
      @doc = doc
      @refs = Hash.new
      @arels = Hash.new
    end

    #
    # Set connection settings for persistent store.
    #
    # First connection has precedence ie. connection selected 
    # in options cannot be overridden in document.
    #
    def connection=(settings)
      ActiveRecord::Base.establish_connection(settings)
      @connection ||= ActiveRecord::Base.connection
    end
    
    #
    # Read connection settings.
    #
    def connection
      @connection
    end

    #
    # Define a store.
    #
    # Yields to a block calling the store for fields and other
    # schema definition. Table is re-created and emptied unless 
    # read_only, and just emptied if data_only.
    #
    def store(table_name_or_sym, &blk)
      table_name = table_name_or_sym.to_s 
      @arels[table_name] = Arel::Table.new(table_name)
      unless @doc.read_only
        if @doc.data_only
          @connection.delete_sql("DELETE from #{table_name}")
        else
          @connection.create_table(table_name, force: true)
        end
      end
      begin
        @table_name = table_name
        self.instance_eval(&blk) if block_given?
      ensure
        @table_name = nil
      end
      table_name_or_sym
    end
        
    #
    # Define a string field.
    #
    def string(name, opts = {})
      @connection.add_column(@table_name, name, :string, opts)
    end
    
    #
    # Define an integer field.
    #
    def integer(name, opts = {})
      @connection.add_column(@table_name, name, :integer, opts)
    end
    
    # 
    # Define a text field.
    #
    def text(name, opts = {})
      @connection.add_column(@table_name, name, :text, opts)
    end
    
    # 
    # Define a datetime field.
    #
    def datetime(name, opts = {})
      @connection.add_column(@table_name, name, :datetime, opts)
    end    
    
  protected
    
    #
    # Insert a row from a hash. 
    #
    def insert(arel, record)
      manager = arel.insert_manager
      columns = record.keys.map { |k| arel[k] }
      manager.insert(columns.zip(record.values))
      @connection.insert(manager)
    end
    
    #
    # Allow use of relation names as calls.
    #
    # If no args then returns an arel for querying.
    #
    def method_missing(name, *args, &block)
      table_name = name.to_s
      if @arels.has_key?(table_name)
        if args.empty?
          return @arels[table_name]
        else
          insert(@arels[table_name], *args)
        end
      else
        super
      end 
    end
        
  end
  
end