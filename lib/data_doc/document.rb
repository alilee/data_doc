require 'rdiscount'
require 'erb'

module DataDoc

  #
  # Class for processing and rendering data_docs.
  #
  # Manages processing and formatting of the document.
  #
  class Document
              
    # 
    # :section: 1. Options
    #
    # Allows access to set processing options prior to document generation.
    #
    
    #
    # Sets up so that default options can be read.
    #
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
    
    # MIME-type for output
    attr_accessor :format 

    # Available mime types that can be generated.
    OUTPUT_TYPES = ['html']

    # output filename
    attr_accessor :output 

    # display verbose output during processing
    attr_accessor :verbose

    # do not change schema or data
    attr_accessor :read_only 

    # do not change schema; truncates tables
    attr_accessor :data_only
    
    # 
    # Sets the database connection that the stores will be using
    #
    def connection=(connection)
    end
    
    # 
    # Sets the layout file option.
    #
    # See #set_layout_file below for format.
    #
    def layout=(filename)
      @layout_filename = filename
    end
        
    #
    # :section: 2. Main function
    # 
        
    #
    # Generate the output for the given input content.
    #
    def generate(content_io)
      erb_content = content_io.read
      begin
        self.untrust
        mark_down = ERB.new(erb_content, 4).result(binding.taint) # $SAFE = 4
      ensure
        self.trust
      end
      content_html = RDiscount.new(mark_down).to_html
      html = wrap_in_layout(content_html)
      @output.write(html)
      0
    end
    
    #
    # :section: 3. DSL for layout file
    #
    
    #
    # Set layout file (from the filename, not the template content itself)
    #
    # Content is html, with ERB placeholders to yield to add content at 
    # appropriate points.
    #
    # [ <%= yield :head %> ] marks where to place any headers defined (see #meta below for an example)
    # [ <%= yield :content %> <em>or</em> <%= yield %> ] marks where to place the processed content from the input file.
    # 
    def set_layout_file(filename)
      self.layout=(filename)
    end
    
    #
    # Default layout if no layout file provided.
    #
    # Simplistic valid html which accepts headers and puts content directly into body tag.
    #
    def self.default_layout
      "<!DOCTYPE html>\n<html>\n<head><%= yield :head %></head>\n<body>\n<%= yield %>\n</body>\n</html>"
    end
    
    #
    # :section: 4. DSL for header tags
    #
  
    #
    # Sets the title tag and emits the title in a classed div.title. 
    #
    def title(text)
      add_header "<title>#{text}</title>"
      "<div class=\"title\">#{text}</div>"
    end
    
    #
    # Adds a meta tag to the headers
    #
    def meta(attrs = {})
      add_header "<meta #{html_attrs(attrs)}>"    
    end

    #
    # Adds a script tag to the headers, yielding for body of tag.
    #
    def script(attrs = {})
      add_header "<script #{html_attrs(attrs)}>#{"\n"+yield+"\n" if block_given?}</script>"    
    end
  
    #
    # Adds a link tag to the headers
    #
    def link(attrs = {})
      add_header "<link #{html_attrs(attrs)}>"
    end
            
    #
    # :section: 5. Protected
    #
    
  protected
          
    #
    # Isolates ERB for layout
    #
    class IsolatedLayoutContext
      # captures binding including any block
      def binding_with_block
        binding
      end
    end

    #
    # Wraps the default layout or a user provided layout around the content. 
    #
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
    
    #
    # Formats a hash as html attributes for insertion into a tag.
    #
    def html_attrs(attrs)
      list = attrs.to_a.map {|k,v| "#{k}=\"#{v}\"" }
      list.join(' ')
    end
    
    #
    # Add another header to the array of headers.
    #
    def add_header(h)
      # Can't use Array#push in $SAFE = 4 
      @headers = @headers + [h]
      h
    end
    
  end
  
end