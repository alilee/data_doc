require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/data_doc'

Hoe.plugin :newgem

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'data_doc' do
  self.developer        'Alister Lee', 'gems@shortepic.com'
  self.rubyforge_name = 'data-doc'
  self.extra_deps =     [['activerecord','~> 3.2.8'],['rdiscount','~> 1.6.8']]
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

task :pkg => :check_manifest
