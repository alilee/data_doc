module DataDoc

  class Document
      
    OUTPUT_TYPES = ['html']
    
    def initialize
      @format = 'html'
      @output = STDOUT
      @verbose = false
      @read_only = false
      @data_only = false
      @connection = nil
    end
    
    attr_accessor :format, :output, :verbose, :read_only, :data_only

    def connection=(connection)
    end
    
    def generate(content)
      @output.write ""
    end
    
  end
  
end