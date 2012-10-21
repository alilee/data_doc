require 'rdiscount'

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
    
    def generate(content_io)
      content = content_io.read
      html = RDiscount.new(content).to_html
      @output.write(html)
    end
    
  end
  
end