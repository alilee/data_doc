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
    # schema definition. 
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
      self.instance_eval(&blk) if block_given?
      table_name_or_sym
    end
    
  end
  
end