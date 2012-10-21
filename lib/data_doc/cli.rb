require 'optparse'
require 'yaml'

module DataDoc
  class CLI
            
    def self.execute(stdout, arguments=[])

      doc = DataDoc::Document.new

      OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          #{DataDoc::DESCRIPTION}

          Usage: #{File.basename($0)} [options] filename

          Options are:
        BANNER
        
        opts.separator ""
        opts.separator "Specific options:"

        opts.on("-c", "--connection FILENAME", 
                "Override document connection settings with FILENAME") do |filename|
          begin
            doc.connection = YAML.load(File.read(filename))
          rescue Exception => e
            STDERR.puts "ERROR with connection file (#{e.message})"
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
                "Put generated output in FILENAME") do |filename|
          begin
            doc.output = File.open(filename, 'w+')
          rescue Exception => e
            STDERR.puts "ERROR with output file (#{e.message})"
            return 1
          end
        end
                
        type_list = DataDoc::Document::OUTPUT_TYPES.join(', ')
        opts.on("-f", "--format TYPE", DataDoc::Document::OUTPUT_TYPES, "Select type of output from #{type_list} (default: #{doc.format})") do |format|
          doc.format = format
        end

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          doc.verbose = v
        end

        opts.separator ""
        opts.separator "Common options:"

        opts.on_tail("-h", "--help", "Show this message") do
          stdout.puts opts
          return
        end

        opts.on_tail("--version", "Show version") do
          stdout.puts DataDoc::VERSION
          return
        end        
        
        opts.parse!(arguments)
        
        if arguments.length != 1 
          STDERR.puts opts
          return 1
        end
                
      end

      begin
        content = File.open(arguments.first, "r")
      rescue Exception => e
        STDERR.puts "ERROR opening content file (#{e.message})"
        return 1
      end
            
      doc.generate(content)
    end
  end
end