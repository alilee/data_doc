require 'rdiscount'
require 'erb'
require 'tempfile'
require 'data_doc/store.rb'
require 'data_doc/present.rb'

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
      @prince_path = 'prince'
      @verbose = false
      @read_only = false
      @data_only = false
      @connection = nil
      @layout_filename = nil
      @output_filename = nil
      @output = STDOUT
      
      @headers = Array.new
      @stores = Hash.new
    end
    
    # MIME-type for output
    attr_accessor :format 

    # Available mime types that can be generated.
    OUTPUT_TYPES = ['html', 'pdf']

    # display verbose output during processing
    attr_accessor :verbose

    # do not change schema or data
    attr_reader :read_only 

    # do not change schema; truncates tables
    attr_accessor :data_only
            
    #
    # Do not change schema or data.
    #
    def read_only=(ro)
      @read_only = ro
      @data_only = ro if ro
    end

    # 
    # Sets the database connection that the stores will be using
    #
    def connection=(conn_filename)
      settings = YAML::load_file(conn_filename)
      set_connection(settings)
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
    # Sets path to find the pdf generator.
    #
    def prince_path=(path)
      @prince_path = path
    end
        
    #
    # name of file to write output into
    #
    def output_filename=(filename)
      @output_stream = nil
      @output_filename = filename
    end

    #
    # Stream to write output into
    #
    def output_stream=(s)
      @output_filename = nil
      @output_stream = s
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
        # @store.taint
        # self.untrust
        mark_down = ERB.new(erb_content, 0).result(binding.taint) # TODO: $SAFE = 4
      ensure
        # self.trust
        # @store.untaint
      end
      content_html = RDiscount.new(mark_down).to_html
      html = wrap_in_layout(content_html)
      write_in_format(html)
    end
    
    #
    # :section: 3. DSL for layout file
    #
    # Each function below includes a usage example which shows how it would be
    # called from within a content file.
    #
    
    #
    # Set layout file (from the filename, not the template content itself)
    #
    #   <% set_layout_file 'myfile.html.erb' %>
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
    # Each function below includes a usage example which shows how it would be
    # called from within a content file.
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
      add_header "<meta #{html_attrs(attrs)} />"    
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
      add_header "<link #{html_attrs(attrs)} />"
    end
            
            
    #
    # :section: 5. DSL for stores
    #
    
    #
    # Specifies ActiveRecord connection settings.
    #
    def set_connection(settings)
      ActiveRecord::Base.establish_connection(settings)
    end
    
    #
    # Fetch from store
    #
    def query(arel_or_sql)
      ActiveRecord::Base.connection.select_all(arel_or_sql)
    end
    
    #
    # Fetch single value from store
    #
    def query_value(arel_or_sql)
      ActiveRecord::Base.connection.select_value(arel_or_sql)
    end
    
    #
    # Define a table store.
    #
    def store(name, opts = {}, &blk)
      @stores[name.to_s] = DataDoc::Store.store(self, name, opts, &blk)
      name
    end
    
    #
    # :section: 6. DSL for presenting tables
    #
    
    #
    # Present a table. Pass a block to set options for display.
    # For more information see DataDoc::Present
    #
    def present(arel_or_str, &blk)
      DataDoc::Present.present(self, arel_or_str, &blk)
    end
            
  protected

    #
    # :section: 9. Protected
    #
              
    #
    # Isolates ERB for layout.
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
    
    #
    # Allow use of relation names as calls for adding or querying.
    #
    # If no args then returns an arel for querying, otherwise assumes add.
    #
    def method_missing(name, *args, &block)
      table_name = name.to_s
      if @stores.has_key?(table_name)
        if args.empty?
          return @stores[table_name].arel
        else
          @stores[table_name].insert(*args) unless @read_only
        end
      else
        super
      end 
    end
    
    #
    # Output to file or stream, in correct format.
    #
    def write_in_format(html)
      html_file = if @format == 'html'
        @output_stream || File.new(@output_filename, 'w+')
      else
        Tempfile.new(['prince','.html'], '.')
      end

      html_file.write(html)
      
      if @format == 'pdf'
        html_file.close
        pdf_filename = @output_filename || (Tempfile.open('prince') {|f| f.close; f.path })
        system("#{@prince_path} -o #{pdf_filename} #{html_file.path}")
        @output_stream.write(File.read(pdf_filename)) if @output_filename.nil?
      end
    end
        
  end
  
end