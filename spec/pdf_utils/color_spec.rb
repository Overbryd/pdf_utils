require 'spec_helper'

describe PdfUtils::Color do
  it "should convert to pdf color" do
    PdfUtils::Color.new(255, 255, 0).to_pdf.should eql([1.0, 1.0, 0.0])
  end
  
  it "should convert to hex color" do
    PdfUtils::Color.new(0, 1.0, 0).to_hex.should eql('00ff00')
  end
  
  it "should convert to rgb values" do
    PdfUtils::Color.new('ff0000').to_rgb.should eql([255, 0, 0])
  end
end
