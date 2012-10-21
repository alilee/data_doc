$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module DataDoc
  VERSION = '0.0.2'
  DESCRIPTION = 'Processes structured data embedded in a markdown document and then renders it into configurable tables.'
end

require 'data_doc/document.rb'
# require 'data_doc/store.rb'
# require 'data_doc/table.rb'
