# hello

rule '.html' => '.md.erb' do |t|
  sh "bin/data_doc -o #{t.name} #{t.source}"
end

example_files = FileList["examples/*.md.erb"].map {|f| f.sub(/.md.erb$/,'.html') }

desc "Generate example files"
task :examples => example_files

desc "Clean up example output"
task :clean_examples do
  example_files.each do |f|
    File.delete(f)
  end
end
