module PdfUtils
  class Info
    attr_reader :pdf_version, :title, :author, :subject, :keywords, :creator, :producer, :tagged, :optimized, :encrypted
    attr_reader :file_size, :mod_date, :creation_date, :pages, :page_size, :page_format
    alias_method :tagged?, :tagged
    alias_method :optimized?, :optimized
    alias_method :encrypted?, :encrypted
    alias_method :modification_date, :mod_date
    
    def initialize(filename)
      raise ArgumentError.new("File does not exist: #{filename}") unless File.exist?(filename)
      info = {}
      PdfUtils::run_command(:pdfinfo, filename).scan(/^([^:]+): +(.*?)?$/) do |property|
        info.store(*property)
      end
      @pdf_version   = info["PDF version"]
      @title         = info["Title"]
      @subject       = info["Subject"]
      @keywords      = info["Keywords"]
      @author        = info["Author"]
      @creator       = info["Creator"]
      @producer      = info["Producer"]
      @pages         = info["Pages"].to_i
      @creation_date = Time.parse(info["CreationDate"]) rescue nil
      @mod_date      = Time.parse(info["ModDate"]) rescue nil
      @page_size     = info["Page size"] =~ /^([\d.]+) x ([\d.]+)/ && [$1.to_f, $2.to_f]
      @page_format   = info["Page size"] =~ /\(([^(]+)\)$/ && $1
      @file_size     = info["File size"] =~ /^(\d+) bytes$/ && $1.to_i
      @optimized     = info["Optimized"] == 'yes'
      @tagged        = info["Tagged"] == 'yes'
      @encrypted     = info["Encrypted"] == 'yes'
    end
    
    def page_dimensions
      [page_width, page_height]
    end
    
    def page_width
      @page_size[0]
    end

    def page_height
      @page_size[1]
    end
  end
end