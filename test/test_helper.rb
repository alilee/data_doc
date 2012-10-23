require 'stringio'
require 'set'
require 'tempfile'
require 'minitest/autorun'
require 'minitest/mock'

require File.dirname(__FILE__) + '/../lib/data_doc'

def temp_file(content)
  @temp_files ||= Set.new
  f = Tempfile.new('test_data_doc')
  @temp_files.add(f)
  f.write(content)
  f.rewind
  f.path
end


# allows yield to call block
def erb(content)
  ERB.new(content).result(binding)
end

# connection to temp database
def test_connection
  settings = {
    adapter: 'sqlite3',
    database: temp_file("")
  }
  ActiveRecord::Base.establish_connection(settings)
  ActiveRecord::Base.connection
end
