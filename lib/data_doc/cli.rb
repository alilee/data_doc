require 'optparse'
require 'yaml'

module DataDoc
  
  #
  # Manages command-line options and arguments.
  #
  class CLI
            
    #
    # Parses the command line and calls the main object.
    #
    # stdout:: IO to redirect output for testing.
    # arguments:: contents of command line
    #
    def self.execute(stdout, arguments=[])

      doc = DataDoc::Document.new
      filename = nil

      OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          #{DataDoc::DESCRIPTION}

          Usage: #{File.basename($0)} [options] filename

          Options are:
        BANNER
        
        opts.separator ""
        opts.separator "Specific options:"

        opts.on("-c", "--connection FILENAME", 
                "Override document connection settings with FILENAME") do |conn_filename|
          begin
            doc.connection = conn_filename
          rescue Exception => e
            stdout.puts "ERROR with connection file (#{e.message})"
            return 1
          end
        end
        
        opts.on("-r", "--read-only", "Use data already in database rather than document data") do |r|
          doc.read_only = r
        end
        
        opts.on("-d", "--data-only", "Use document data but do not change database schema") do |d|
          doc.data_only = d
        end

        opts.on("-o", "--output FILENAME", 
                "Put generated output in FILENAME") do |f|  
          filename = f
        end
                
        type_list = DataDoc::Document::OUTPUT_TYPES.join(', ')
        opts.on("-f", "--format TYPE", DataDoc::Document::OUTPUT_TYPES, "Select type of output from #{type_list} (default: #{doc.format})") do |format|
          doc.format = format
        end
        
        opts.on("-p", "--prince PATH", 
                "Path for prince pdf generator") do |p|  
          doc.prince = p
        end        

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          doc.verbose = v
        end

        opts.separator ""
        opts.separator "Common options:"

        opts.on_tail("-h", "--help", "Show this message") do
          stdout.puts opts
          return 0
        end

        opts.on_tail("--version", "Show version") do
          stdout.puts DataDoc::VERSION
          return 0
        end        
        
        opts.parse!(arguments)
        
        if arguments.length != 1 
          stdout.puts "ERROR missing input file"
          return 1
        end
                
      end

      begin
        content = File.open(arguments.first, "r")
      rescue Exception => e
        stdout.puts "ERROR opening content file (#{e.message})"
        return 1
      end
            
      result = doc.generate(content)
      unless filename.nil?
        begin
          File.open(filename, 'w+') do |f|
            f.write(result)
          end
        rescue Exception => e
          stdout.puts "ERROR with output file (#{e.message})"
          return 1
        end
      else
        stdout.write(result)
      end
      0      
    end
  end
end