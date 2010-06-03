require 'spec_helper'

describe PdfUtils::Info do
  it "should extract meta information from the pdf" do
    @info = PdfUtils::Info.new(fixture_file_path('marketing.pdf'))
    
    @info.tagged        .should eql(false)
    @info.keywords      .should eql("")
    @info.page_size     .should eql([595.0, 842.0])
    @info.producer      .should eql("Mac OS X 10.5.6 Quartz PDFContext")
    @info.optimized     .should eql(false)
    @info.title         .should eql("marketing")
    @info.mod_date      .should eql(Time.parse('2010/01/12 17:34:51 +0100'))
    @info.creator       .should eql("Preview")
    @info.file_size     .should eql(33179)
    @info.pdf_version   .should eql("1.4")
    @info.creation_date .should eql(Time.parse('2009/02/04 13:42:55 +0100'))
    @info.encrypted     .should eql(false)
    @info.author        .should eql("Alexander Lang")
    @info.page_format   .should eql("A4")
    @info.pages         .should eql(3)
    @info.subject       .should eql("")
  end
end
