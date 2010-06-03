require 'spec_helper'

describe PdfUtils do
  
  describe "toc" do

    it "should return an array of toc entries" do
      PdfUtils.should_receive(:run_command).with(:pdftk, "stub.pdf dump_data").and_return(
        "BookmarkTitle: Content\nBookmarkLevel: 1\nBookmarkPageNumber: 3\nBookmarkTitle: Intro\nBookmarkLevel: 2\nBookmarkPageNumber: 4")
      PdfUtils::toc('stub.pdf').should eql([["Content",1,3], ["Intro",2,4]])
    end
    
    it "should not add an toc entry with page number < 1" do
      PdfUtils.stub(:run_command => "BookmarkTitle: Content\nBookmarkLevel: 1\nBookmarkPageNumber: 0")
      PdfUtils::toc('stub.pdf').should be_empty
    end

    it "should be empty if the document has no toc data" do
      PdfUtils.should_receive(:run_command).with(:pdftk, "stub.pdf dump_data").and_return(
        "InfoKey: Creator\nInfoValue: The Pragmatic Bookshelf")
      PdfUtils::toc('stub.pdf').entries.should be_empty
    end
  end

  describe "slice" do
    
    it "should slice into a new pdf" do
      sliced_path = Tempfile.new('sliced').path
      PdfUtils::slice(fixture_file_path('marketing.pdf'), 2, 3, sliced_path)
      PdfUtils::info(sliced_path).pages.should eql(2)
    end
    
    it "should slice the given file" do
      sliced_path = duplicate_fixture_file('marketing.pdf').path
      PdfUtils::slice!(sliced_path, 2, 3)
      PdfUtils::info(sliced_path).pages.should eql(2)
    end
    
    it "should raise an error if pdftk fails to slice the pdf" do
      lambda {
        PdfUtils::slice('does/not/exist.pdf', 2, 3, 'does/not/exist/either.pdf')
      }.should raise_error(RuntimeError)
    end
  end
  
  describe "watermark" do
    
    before :each do
      @pdf_path = fixture_file_path('marketing.pdf')
    end

    it "should watermark into a new pdf" do
      watermarked_path = Tempfile.new('watermarked').path
      PdfUtils::watermark(@pdf_path, watermarked_path) do |pdf|
        pdf.text "WATERMARKED PDF", :align => :center, :size => 8
      end
      pdf_text = PdfUtils::to_text(watermarked_path)
      pdf_text.should include('WATERMARKED PDF')
      pdf_text.should include('Beltz Verlag Weinheim')
    end
    
    it "should watermark the given file" do
      watermarked_path = duplicate_fixture_file('marketing.pdf').path
      PdfUtils::watermark!(watermarked_path) do |pdf|
        pdf.text "WATERMARKED PDF", :align => :center, :size => 8
      end
      pdf_text = PdfUtils::to_text(watermarked_path)
      pdf_text.should include('WATERMARKED PDF')
      pdf_text.should include('Beltz Verlag Weinheim')
    end
    
    it "should pass options to the watermark pdf" do
      Prawn::Document.should_receive(:generate).with(anything, :page_size => [25, 25])
      PdfUtils::watermark(@pdf_path, Tempfile.new('target').path, :page_size => [25, 25]) {}
    end
  end
  
  describe "annotate" do
    
    before :each do
      @pdf_path = fixture_file_path('page.pdf')
      @annotations = [{
        :Type     => :Annot,
        :Subtype  => :Text,
        :Name     => :Comment,
        :Rect     => [10, 10, 34, 34],
        :Contents => 'Dies ist eine Notiz.',
        :C        => PdfUtils::Color.new('fdaa00').to_pdf,
        :M        => Time.now,
        :F        => 4
      }]
    end
    
    it "should annotate into a new pdf" do
      annotated_path = Tempfile.new('annotated').path
      PdfUtils::annotate(@pdf_path, @annotations, annotated_path)
      annotations = PdfUtils::annotations(annotated_path)
      annotations.should have(1).item
      annotations.first[:Contents].should eql('Dies ist eine Notiz.')
    end
  end

  describe "thumbnail" do

    it "should create a thumbnail of the given page" do
      source = fixture_file_path('marketing.pdf')
      target = File.join(Dir.tmpdir, 'marketing.png')
      FileUtils.rm(target) if File.exists?(target)
      PdfUtils::thumbnail(source, :page => '3', :target => target)
      File.should be_exists(target)
    end
  end
  
  describe "snapshot" do

    it "should rasterize the given page" do
      path = duplicate_fixture_file('marketing.pdf').path
      original_info = PdfUtils::info(path)

      PdfUtils::snapshot!(path, :page => 2)

      info = PdfUtils::info(path)
      info.pages.should eql(1)
      info.page_width. should be_close(original_info.page_width , 1.0)
      info.page_height.should be_close(original_info.page_height, 1.0)
      info.page_format.should eql(original_info.page_format)
    end
  end
end