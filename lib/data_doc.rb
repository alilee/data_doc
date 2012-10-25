$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

#
# Encompasses the data_doc classes.
#
module DataDoc
  # Gem version
  VERSION = '0.2.0'
  # A summary of purpose of the tool.  
  DESCRIPTION = 'Processes structured data embedded in a markdown document and then renders it into configurable tables.'
end

require 'data_doc/document.rb'
