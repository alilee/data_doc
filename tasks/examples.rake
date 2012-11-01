rule '.html' => '.md.erb' do |t|
  sh "bin/data_doc -o #{t.name} #{t.source}"
end

rule '.pdf' => '.md.erb' do |t|
  sh "bin/data_doc -f 'pdf' -o #{t.name} #{t.source}"
end

example_files = FileList["examples/*.md.erb"]
html_files = example_files.map {|f| f.sub(/.md.erb$/,'.html') }
pdf_files = example_files.map {|f| f.sub(/.md.erb$/,'.pdf') }

desc "Generate example files"
task :examples => html_files

desc "Generate example files in PDF format"
task :examples_pdf => pdf_files

desc "Clean up example output and dbs"
task :clean_examples do
  example_files.each do |f|
    output_file = f.sub(/.md.erb$/, '.html')
    db_file = f.sub(/.md.erb$/, '.db')
    pdf_file = f.sub(/.md.erb$/, '.pdf')
    File.delete(output_file) if File.exists?(output_file)
    File.delete(db_file) if File.exists?(db_file)
    File.delete(pdf_file) if File.exists?(pdf_file)
  end
end
