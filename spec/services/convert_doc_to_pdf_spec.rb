require "rails_helper"

RSpec.describe ConvertDocToPdf do
  describe ".call" do
    it "converts a docx to a pdf" do
      with_tmp_dir do |tmp_dir|
        docx = create(:imports_docx)
        stub_soffice_install
        fake_pdf_conversion(docx.id, docx.file, tmp_dir:) => {word_path:, pdf_path:}

        File.open(word_path) do |word|
          allow_any_instance_of(ActiveStorage::Attachment).to receive(:open).and_yield(word)

          result = described_class.call(docx.id, docx.file, tmp_dir)

          expect(result).to eq(File.join(tmp_dir, docx.id, "hello.pdf"))
        end
      end
    end

    it "converts a doc to a pdf" do
      with_tmp_dir do |tmp_dir|
        doc = create(:imports_doc)
        stub_soffice_install
        fake_pdf_conversion(doc.id, doc.file, tmp_dir:) => {word_path:, pdf_path:}

        File.open(word_path) do |word|
          allow_any_instance_of(ActiveStorage::Attachment).to receive(:open).and_yield(word)

          result = described_class.call(doc.id, doc.file, tmp_dir)

          expect(result).to eq(File.join(tmp_dir, doc.id, "hello.pdf"))
        end
      end
    end

    it "raises if libreoffice not installed" do
      doc = create(:imports_doc)
      stub_soffice_install(installed: false)

      expect {
        described_class.call(doc.id, doc.file)
      }.to raise_exception(described_class::DependencyNotFoundError)
    end

    it "raises if conversion failed" do
      with_tmp_dir do |dir|
        doc = create(:imports_doc)
        stub_soffice_install
        stub_soffice_conversion(successful: false)

        expect {
          described_class.call(doc.id, doc.file)
        }.to raise_exception(described_class::FileConversionError)
      end
    end
  end

  def with_tmp_dir
    Dir.mktmpdir("pdf_conversion") { |dir| yield dir }
  end

  def stub_soffice_install(installed: true)
    allow(Kernel).to receive(:system)
      .with("soffice --version")
      .and_return(installed)
  end

  def stub_soffice_conversion(successful: true)
    allow(Kernel).to receive(:system)
      .with(/soffice --headless --convert-to pdf .*/)
      .and_return(successful)
  end

  # Since we are not actually invoking `soffice` in tests, do a fake PDF
  # "conversion" by just making a a .docx file and a .pdf file with the same
  # name.
  def fake_pdf_conversion(id, attachment, tmp_dir:)
    stub_soffice_conversion

    subdir = "#{tmp_dir}/#{id}"
    FileUtils.mkdir_p(subdir)
    word_path = "#{subdir}/hello.docx"
    File.open(word_path, "wb") { _1.write(attachment.download) }
    pdf_path = "#{subdir}/hello.pdf"
    File.write(pdf_path, "hello")

    {
      subdir:,
      word_path:,
      pdf_path:
    }
  end
end
