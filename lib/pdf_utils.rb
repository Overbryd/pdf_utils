require 'rubygems'
require 'active_support'
require 'prawn'
require 'pdf/reader'

require 'in_tempdir'
require 'pdf_utils/info'
require 'pdf_utils/color'

module PdfUtils
  
  class << self
    
    include InTmpdir
    
    def objects(filename, filter={})
      uncompress(filename) do |uncompressed|
        PDF::Hash.new(uncompressed).values.select do |obj|
          if obj.kind_of?(Hash)
            if obj.has_key?(:Contents) && obj[:Contents].kind_of?(String)
              obj[:Contents] = Iconv.conv('utf-8', 'utf-16', obj[:Contents]) 
            end
            filter.detect {|k, v| obj[k] == v }
          end 
        end
      end
    end
    
    def annotations(filename)
      objects(filename, :Type => :Annot)
    end
    
    def info(filename)
      PdfUtils::Info.new(filename)
    end
    
    def toc(filename)
      toc = []
      if meta_data = run_command(:pdftk, "#{filename} dump_data")
        entry = nil
        meta_data.scan(/^Bookmark(\w+): (.*)$/) do |(key, value)|
          case key
            when "Title"
              entry = [value]
            when "Level"
              entry << value.to_i
            when "PageNumber"
              if value.to_i > 0
                entry << value.to_i
                toc << entry 
              end
          end
        end
      end
      toc
    end

    def to_text(filename, target = nil)
      run_command(:pdftotext, "-layout -enc UTF-8 #{filename} #{target || '-'}", !!target)
    end
    
    def to_swf(source, target)
      run_command(:pdf2swf, "-T 9 -f -s transparent -s detectspaces #{source} -o #{target}")
    end
    
    def uncompress(source, target=nil, &block)
      target ||= tmp_file_name("uncompress")
      run_command(:pdftk, "#{source} output #{target} uncompress")
      if block_given?
        begin
          yield(target)
        ensure
          FileUtils.rm(target)
        end
      end
    end
    
    def slice(source, from_page, to_page, target)
      run_command(:pdftk, "#{source} cat #{from_page}-#{to_page} output #{target}")
    end
    
    def slice!(source, from_page, to_page)
      target = tmp_file_name("slice")
      slice(source, from_page, to_page, target)
      FileUtils.mv(target, source)
    end
    
    def burst(source, target)
      run_command(:pdftk, "#{source} burst output #{target}")
    end
    
    def cat(source, target)
      run_command(:pdftk, "#{source} cat output #{target}")
    end
    
    def watermark(source, target, options = {}, &block)
      raise ArgumentError.new("No block given") unless block_given?
      options[:page_size] ||= info(source).page_dimensions
      with_tmpfile("watermark") do |watermarked|
        Prawn::Document.generate(watermarked, options, &block)
        run_command(:pdftk, "#{source} background #{watermarked} output #{target}")
      end
    end
    
    def watermark!(source, options = {}, &block)
      target = tmp_file_name("watermark_merge")
      watermark(source, target, options, &block)
      FileUtils.mv(target, source)      
    end

    def annotate(source, annotations, target, options = {})
      options[:page_size] ||= info(source).page_dimensions
      with_tmpfile("annotate") do |annotated|
        Prawn::Document.generate(annotated, options) do |pdf|
          annotations.each do |annotation| 
            pdf.annotate(annotation)
          end
        end
        run_command(:pdftk, "#{annotated} background #{source} output #{target}")
      end
    end

    def annotate!(source, annotations, options = {})
      target = tmp_file_name("annotate_merge")
      annotate(source, annotations, target, options)
      FileUtils.mv(target, source)
    end
    
    THUMBNAIL_DEFAULTS = { :density => 150, :size => '50%', :format => 'jpg', :quality => 85, :target => nil, :page => 1 }.freeze
    
    def thumbnail(source, options = {})
      options.assert_valid_keys(THUMBNAIL_DEFAULTS.keys)

      options = THUMBNAIL_DEFAULTS.merge(options)
      target  = options[:target] || source.sub(/(\.\w+)?$/, ".#{options[:format]}")
      source  = "#{source}[#{options[:page].to_i-1}]"
      
      run_command(:convert, [
        '-density'          , options[:density],
        source,
        '-colorspace'       , :rgb,
        '-thumbnail'        , options[:size],
        '-quality'          , options[:quality],
        target        
      ].join(' '))
      return target
    end
    
    SNAPSHOT_DEFAULTS = { :density => 150, :compress => 'JPEG', :quality => 85 }.freeze
    
    def snapshot(source, target, options = {})
      options.assert_valid_keys(SNAPSHOT_DEFAULTS.keys + [:page])
      page_number = (options.delete(:page) || 1).to_i
      source  = "#{source}[#{page_number-1}]"
      options = SNAPSHOT_DEFAULTS.merge(options).map{ |opt,val| "-#{opt} #{val}" } << "#{source} #{target}"
      run_command(:convert, options)
    end
    
    def snapshot!(source, options = {})
      snapshot(source, source, options)
    end
    
    def run_command(command, args, reroute_errors = true)
      command = [command, args]
      command << '2>&1' if reroute_errors
      command = command.join(' ')
      output = `#{command}`
      if $?.success?
        output
      else
        raise RuntimeError.new("Command failed: #{command}\n#{output}")
      end
    end
  end
end