require "rails_helper"

RSpec.describe PdfToText do
  describe ".call" do
    it "converts pdf to text" do
      pdf_text = "Appendix A\n\n Welder (Industrial)\n(Competency based)\n\n"

      reader_mock = instance_double "PDF::Reader"
      allow(PDF::Reader).to receive(:new).and_return(reader_mock)
      allow(reader_mock).to receive(:pages).and_return([instance_double("PDF::Reader::Page", text: pdf_text)])
    end
  end
end
