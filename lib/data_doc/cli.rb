require 'optparse'
require 'yaml'

module DataDoc
  class CLI
    def self.execute(stdout, arguments=[])

      options = {
        :verbose => false,
        :read_only => false,
        :data_only => false,
        :connection => nil
      }
      mandatory_options = %w(  )

      OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          Processes structured data embedded in a markdown document and 
          then renders it into configurable tables.

          Usage: #{File.basename($0)} [options] filename

          Options are:
        BANNER
        
        opts.separator ""
        opts.separator "Specific options:"

        opts.on("-c", "--connection FILENAME", 
                "Override document connection settings with FILENAME") do |filename|
          begin
            options[:connection] = YAML.load(File.read(filename))
          rescue Exception => e
            STDERR.puts "ERROR with connection file (#{e.message})"
            return 1
          end
        end
        
        opts.on("-r", "--read-only", "Use data already in database rather than document data") do |r|
          options[:read_only] = r
        end
        
        opts.on("-d", "--data-only", "Use document data but do not change database schema") do |d|
          options[:data_only] = d
        end

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options[:verbose] = v
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

        if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
          STDERR.puts opts; 
          return 1
        end
      end

      # do stuff
      stdout.puts "#{options.inspect}"
      stdout.puts "---"
      stdout.puts "#{arguments.inspect}"
      
      0 # exit code
    end
  end
end