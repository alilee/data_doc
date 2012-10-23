# hello

rule '.html' => '.md.erb' do |t|
  sh "bin/data_doc -o #{t.name} #{t.source}"
end

example_files = FileList["examples/*.md.erb"]
output_files = example_files.map {|f| f.sub(/.md.erb$/,'.html') }

desc "Generate example files"
task :examples => output_files

desc "Clean up example output and dbs"
task :clean_examples do
  example_files.each do |f|
    output_file = f.sub(/.md.erb$/, '.html')
    db_file = f.sub(/.md.erb$/, '.db')
    File.delete(output_file) if File.exists?(output_file)
    File.delete(db_file) if File.exists?(db_file)
  end
end
