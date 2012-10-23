# hello

desc "Generate example files"
example_files = FileList["examples/*.md.erb"].map {|f| f.sub(/.md.erb$/,'.html') }
task :examples => example_files

rule '.html' => '.md.erb' do |t|
  sh "bin/data_doc -o #{t.name} #{t.source}"
end