begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "pdf_utils"
    gemspec.summary = "PdfUtils abstracts a lot of well working UNIX tools for PDF files"
    gemspec.description = <<-DESC
    Requires xpdf, pdftk, swftools/pdf2swf and imagemagick.
    You can check their functionality by running `$ rake check_system_dependencies´.
    DESC
    gemspec.email = "l.rieder@gmail.com"
    gemspec.homepage = "http://github.com/Overbryd/pdf_utils"
    gemspec.authors = ["Lukas Rieder", "Andreas Korth"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'

desc "Run all examples"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts = ['--colour', '--format specdoc']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

task :check_system_dependencies do
  load File.join(File.dirname(__FILE__), 'script', 'check_system_dependencies')
end