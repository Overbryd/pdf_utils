require 'tmpdir'

module InTmpdir

  private
  
  def in_tmpdir(dirname='tmp')
    dirname = tmp_file_name(dirname)
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
    begin
      yield(dirname)
    ensure
      FileUtils.rm_rf(dirname) if File.exists?(dirname)
    end
  end
  
  def with_tmpfile(filename='tmp')
    filename = tmp_file_name(filename)
    begin
      yield(filename)
    ensure
      FileUtils.rm_rf(filename) if File.exists?(filename)
    end
  end
  
  def tmp_file_name(name='tmp')
    File.join(Dir.tmpdir, [$$.to_s(16), object_id.to_s(16), name].join('_'))
  end
end