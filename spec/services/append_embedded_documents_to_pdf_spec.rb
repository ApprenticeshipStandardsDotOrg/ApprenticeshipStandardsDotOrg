require "rails_helper"

RSpec.describe AppendEmbeddedDocumentsToPdf do
  it "leaves ordinary Word conversions alone" do
    path = "unchanged.pdf"
    expect(Open3).not_to receive(:capture2e)

    expect(described_class.call(source_path: Rails.root.join("spec/fixtures/files/document.doc"), pdf_path: path)).to eq path
  end

  it "fails visibly when an embedded object cannot be recovered" do
    allow(ExtractEmbeddedDocuments).to receive(:call).and_return(ExtractEmbeddedDocuments::Result.new(paths: [], unsupported: ["unknown object"]))

    expect { described_class.call(source_path: "source.doc", pdf_path: "converted.pdf") }
      .to raise_error(ConvertDocToPdf::FileConversionError, /Unsupported embedded/)
  end

  it "appends packaged PDFs to the original pages and cleans up temporary files" do
    Dir.mktmpdir do |directory|
      source = File.join(directory, "source.doc")
      pdf = File.join(directory, "converted.pdf")
      fixture = Rails.root.join("spec/fixtures/files/pixel1x1.pdf")
      FileUtils.cp(fixture, pdf)
      Ole::Storage.open(source, "w") do |ole|
        ole.dir.mkdir("ObjectPool")
        ole.dir.mkdir("ObjectPool/attachment")
        ole.file.open("ObjectPool/attachment/CONTENTS", "w") { |io| io.write(File.binread(fixture)) }
      end
      extraction_directory = nil
      allow(Open3).to receive(:capture2e) do |*command|
        expect(command.first).to eq "pdfunite"
        expect(command[1]).to eq pdf
        expect(File.binread(command[2])).to eq File.binread(fixture)
        extraction_directory = File.dirname(command[2])
        File.binwrite(command.last, "merged PDF")
        ["", instance_double(Process::Status, success?: true)]
      end

      described_class.call(source_path: source, pdf_path: pdf)

      expect(File.binread(pdf)).to eq "merged PDF"
      expect(Dir.exist?(extraction_directory)).to be false
    end
  end
end
