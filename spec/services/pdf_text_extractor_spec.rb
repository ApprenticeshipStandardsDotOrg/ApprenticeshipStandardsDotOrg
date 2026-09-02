require "rails_helper"

RSpec.describe PdfTextExtractor do
  describe "#call" do
    it "uses layout-preserving pdftotext output when available" do
      file = fake_file("pdf")
      allow(Open3).to receive(:capture2).with("pdftotext", "-v").and_return(["", instance_double(Process::Status, success?: false, exitstatus: 99)])
      allow(Open3).to receive(:capture2).with("pdftotext", "-layout", "-enc", "UTF-8", kind_of(String), "-").and_return(["Appendix A\nWork Process     Hours", instance_double(Process::Status, success?: true)])

      expect(described_class.new(file).call).to eq "Appendix A\nWork Process     Hours"
    end

    it "falls back to PDF::Reader when pdftotext returns blank text" do
      file = fake_file("pdf")
      reader = instance_double(PDF::Reader)
      page = instance_double("PDF::Reader::Page", text: "Fallback text")

      allow(Open3).to receive(:capture2).with("pdftotext", "-v").and_return(["", instance_double(Process::Status, success?: false, exitstatus: 99)])
      allow(Open3).to receive(:capture2).with("pdftotext", "-layout", "-enc", "UTF-8", kind_of(String), "-").and_return(["", instance_double(Process::Status, success?: true)])
      allow(PDF::Reader).to receive(:new).and_return(reader)
      allow(reader).to receive(:pages).and_return([page])

      expect(described_class.new(file).call).to eq "--- Page 1 ---\nFallback text"
    end

    it "falls back to PDF::Reader when pdftotext is unavailable" do
      file = fake_file("pdf")
      reader = instance_double(PDF::Reader)
      page = instance_double("PDF::Reader::Page", text: "Fallback text")

      allow(Open3).to receive(:capture2).with("pdftotext", "-v").and_raise(Errno::ENOENT)
      allow(PDF::Reader).to receive(:new).and_return(reader)
      allow(reader).to receive(:pages).and_return([page])

      expect(described_class.new(file).call).to eq "--- Page 1 ---\nFallback text"
    end
  end

  def fake_file(content)
    Class.new do
      define_method(:initialize) { |file_content| @file_content = file_content }
      define_method(:open) { |&block| block.call(StringIO.new(@file_content)) }
    end.new(content)
  end
end
