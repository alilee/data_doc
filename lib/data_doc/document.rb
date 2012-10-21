require 'rdiscount'
require 'erb'

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
      @layout_filename = nil
      
      @headers = Array.new
    end
    
    attr_accessor :format, :output, :verbose, :read_only, :data_only

    # 
    # options
    #
    
    def connection=(connection)
    end
    
    def layout=(filename)
      @layout_filename = filename
    end
        
    #
    # main function
    # 
    
    def generate(content_io)
      erb_content = content_io.read
      self.untrust
      mark_down = ERB.new(erb_content, 4).result(binding.taint) # $SAFE = 4
      self.trust
      content_html = RDiscount.new(mark_down).to_html
      html = wrap_in_layout(content_html)
      @output.write(html)
      0
    end
    
    #
    # DSL - protected from $SAFE = 4
    #
    
    def set_layout_file(filename)
      self.layout=(filename)
    end
    
    #
    # DSL <head> tags
    #
  
    def title(text)
      add_header "<title>#{text}</title>"
      "<div class=\"title\">#{text}</div>"
    end
    
    def meta(attrs = {})
      add_header "<meta #{html_attrs(attrs)}>"    
    end

    def script(attrs = {})
      add_header "<script #{html_attrs(attrs)}>#{"\n"+yield+"\n" if block_given?}</script>"    
    end
  
    def link(attrs = {})
      add_header "<link #{html_attrs(attrs)}>"
    end
    
    #
    # Layout
    #
    
    def self.default_layout
      "<!DOCTYPE html>\n<html>\n<head><%= yield :head %></head>\n<body>\n<%= yield %>\n</body>\n</html>"
    end
        
  protected
          
    class IsolatedLayoutContext
      def binding_with_block
        binding
      end
    end

    def wrap_in_layout(content)
      @layout ||= @layout_filename.nil? ? DataDoc::Document.default_layout : File.read(@layout_filename)
      block_binding = IsolatedLayoutContext.new.binding_with_block do |section|
        case section.to_s
        when 'head'
          @headers.join("\n")
        else
          content
        end
      end
      ERB.new(@layout, 4, '<>').result(block_binding.taint) # $SAFE = 4
    end
    
    def html_attrs(attrs)
      list = attrs.to_a.map {|k,v| "#{k}=\"#{v}\"" }
      list.join(' ')
    end
    
    def add_header(h)
      @headers = @headers + [h]
      h
    end
    
  end
  
end