require 'optparse'

module DataDoc
  class CLI
    def self.execute(stdout, arguments=[])

      options = {
        :path     => '~'
      }
      mandatory_options = %w(  )

      OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          Processes structured data embedded in a markdown document and 
          then renders it into configurable tables.

          Usage: #{File.basename($0)} [options]

          Options are:
        BANNER
        opts.separator ""
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)

        if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
          stdout.puts opts; exit
        end
      end

      path = options[:path]

      # do stuff
      stdout.puts "To update this executable, look in lib/data_doc/cli.rb"
    end
  end
end