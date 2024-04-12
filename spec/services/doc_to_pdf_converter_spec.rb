require "rails_helper"

RSpec.describe DocToPdfConverter do
  describe ".convert" do
    it "converts a docx to a pdf" do
      with_tmp_dir do |tmp_dir|
        source_file = create(:source_file, :docx)
        import = source_file.standards_import
        attachment = source_file.active_storage_attachment
        stub_soffice_install
        fake_pdf_conversion(source_file, tmp_dir:) => {word_path:, pdf_path:}

        File.open(word_path) do |word|
          allow_any_instance_of(ActiveStorage::Attachment).to receive(:open).and_yield(word)

          described_class.convert(source_file, tmp_dir:)

          expect(import.reload.files.size).to eql(2)
          most_recent_file = import.files.order(:created_at).last
          pdf_filename = attachment.filename.to_s.gsub(".docx", ".pdf")
          expect(most_recent_file.filename.to_s).to eql(pdf_filename)
          expect(source_file.reload.link_to_pdf_filename).to eql(pdf_filename)
        end
      end
    end

    it "converts a doc to a pdf" do
      with_tmp_dir do |tmp_dir|
        source_file = create(:source_file, :doc)
        import = source_file.standards_import
        attachment = source_file.active_storage_attachment
        stub_soffice_install
        fake_pdf_conversion(source_file, tmp_dir:) => {word_path:, pdf_path:}

        File.open(word_path) do |word|
          allow_any_instance_of(ActiveStorage::Attachment).to receive(:open).and_yield(word)

          described_class.convert(source_file, tmp_dir:)

          expect(import.reload.files.size).to eql(2)
          most_recent_file = import.files.order(:created_at).last
          pdf_filename = attachment.filename.to_s.gsub(".doc", ".pdf")
          expect(most_recent_file.filename.to_s).to eql(pdf_filename)
          expect(source_file.reload.link_to_pdf_filename).to eql(pdf_filename)
        end
      end
    end

    it "will do nothing if file cannot be converted" do
      with_tmp_dir do |tmp_dir|
        source_file = create(:source_file)
        allow(source_file).to receive(:can_be_converted_to_pdf?).and_return(false)
        expect_any_instance_of(ActiveStorage::Attachment).to_not receive(:open)

        described_class.convert(source_file, tmp_dir:)
      end
    end

    it "raises if libreoffice not installed" do
      source_file = create(:source_file, :docx)
      stub_soffice_install(installed: false)

      expect {
        described_class.convert(source_file)
      }.to raise_exception(described_class::DependencyNotFoundError)
    end

    it "raises if conversion failed" do
      with_tmp_dir do |dir|
        source_file = create(:source_file, :docx)
        stub_soffice_install
        stub_soffice_conversion(successful: false)

        expect {
          described_class.convert(source_file, tmp_dir: dir)
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
  def fake_pdf_conversion(source_file, tmp_dir:)
    stub_soffice_conversion

    subdir = "#{tmp_dir}/#{source_file.id}"
    FileUtils.mkdir_p(subdir)
    word_path = "#{subdir}/hello.docx"
    attachment = source_file.active_storage_attachment
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
