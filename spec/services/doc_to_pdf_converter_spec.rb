require "rails_helper"

RSpec.describe DocToPdfConverter do
  describe ".convert_all" do
    it "converts docx files" do
      pdf_file = create(:standards_import, :with_files).source_files.first
      docx_file = create(:standards_import, :with_docx_file_with_attachments).source_files.first
      expect(described_class::ConvertJob)
        .not_to receive(:perform_later)
        .with(pdf_file)
      expect(described_class::ConvertJob)
        .to receive(:perform_later)
        .with(docx_file)

      described_class.convert_all
    end

    it "doesn't convert a source file which already had a redacted_source_file" do
      source_file = create(:source_file, :with_redacted_file)
      expect(described_class::ConvertJob)
        .not_to receive(:perform_later)
        .with(source_file)

      described_class.convert_all
    end
  end

  describe ".convert" do
    it "converts a docx to a pdf" do
      with_tmp_dir do |tmp_dir|
        source_file = create(:standards_import, :with_docx_file).source_files.first
        attachment = source_file.active_storage_attachment
        stub_soffice_install
        fake_pdf_conversion(source_file, tmp_dir:) => {docx_path:, pdf_path:}

        File.open(docx_path) do |docx|
          allow_any_instance_of(ActiveStorage::Attachment).to receive(:open).and_yield(docx)

          described_class.convert(source_file, tmp_dir:)

          redacted_file = source_file.reload.redacted_source_file
          expect(redacted_file).to be_attached
          expect(redacted_file.filename.to_s).to eql(
            attachment.filename.to_s.gsub(".docx", ".pdf")
          )
        end
      end
    end

    it "raises if libreoffice not installed" do
      source_file = create(:source_file)
      stub_soffice_install(installed: false)

      expect {
        described_class.convert(source_file)
      }.to raise_exception(described_class::DependencyNotFoundError)
    end

    it "raises if conversion failed" do
      with_tmp_dir do |dir|
        source_file = create(:source_file)
        allow(DocxFile).to receive(:has_embedded_files?).and_return(false)
        stub_soffice_install
        stub_soffice_conversion(successful: false)

        expect {
          described_class.convert(source_file, tmp_dir: dir)
        }.to raise_exception(described_class::FileConversionError)
      end
    end

    it "does not attempt to convert a docx with attachments" do
      with_tmp_dir do |dir|
        source_file = create(:standards_import, :with_docx_file_with_attachments).source_files.first
        stub_soffice_install

        described_class.convert(source_file, tmp_dir: dir)

        expect(source_file.reload.redacted_source_file).not_to be_attached
      end
    end
  end

  def with_tmp_dir
    Dir.mktmpdir("pdf_conversion") { |dir| yield dir }
  end

  def stub_soffice_install(installed: true)
    allow(Kernel).to receive(:system)
      .with("command -v soffice")
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
  def fake_pdf_conversion(source_file, tmp_dir:)
    stub_soffice_conversion

    subdir = "#{tmp_dir}/#{source_file.id}"
    FileUtils.mkdir_p(subdir)
    docx_path = "#{subdir}/hello.docx"
    attachment = source_file.active_storage_attachment
    File.open(docx_path, "wb") { _1.write(attachment.download) }
    pdf_path = "#{subdir}/hello.pdf"
    File.write(pdf_path, "hello")

    {
      subdir:,
      docx_path:,
      pdf_path:
    }
  end
end
