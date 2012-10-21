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
    
  end
  
end