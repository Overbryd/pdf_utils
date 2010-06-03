require "rubygems"
require 'test/unit'
require "spec"
require 'tempfile'

require 'pdf_utils'

def fixture_file_path(file)
  File.join(File.dirname(__FILE__), 'fixtures', file)
end

def fixture_file(file)
  File.open(fixture_file_path(file))
end

def duplicate_fixture_file(file)
  tempfile = Tempfile.new(File.basename(file))
  FileUtils.cp_r(fixture_file_path(file), tempfile.path)
  tempfile
end