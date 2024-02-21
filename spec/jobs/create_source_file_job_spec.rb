require "rails_helper"

RSpec.describe CreateSourceFileJob, "#perform", type: :job do
  it "creates source file record" do
    file = file_fixture("pixel1x1.pdf")
    import = create(:standards_import, files: [file])
    attachment = import.files.first

    expect {
      described_class.new.perform(attachment)
    }.to change(SourceFile, :count).by(1)

    source_file = SourceFile.last
    expect(source_file.active_storage_attachment).to eq import.files.first
  end

  it "calls DocToPdfConverter job if new record" do
    file = file_fixture("document.docx")
    import = create(:standards_import, files: [file])
    attachment = import.files.first

    expect(DocToPdfConverterJob).to receive(:perform_later).once

    described_class.new.perform(attachment)
  end

  it "does not call DocToPdfConverter job if source file is persisted" do
    source_file = create(:source_file, :docx)

    expect(DocToPdfConverterJob).to_not receive(:perform_later)

    described_class.new.perform(source_file.active_storage_attachment)
  end

  it "marks source_file courtesy_notification as pending if import courtesy notification is pending" do
    import = create(:standards_import, :with_files, email: "foo@example.com", name: "Foo", courtesy_notification: :pending)
    attachment = import.files.first

    described_class.new.perform(attachment)

    source_file = SourceFile.last
    expect(source_file).to be_courtesy_notification_pending
  end

  it "does not mark source_file courtesy_notification as pending if import courtesy notification is not_required" do
    import = create(:standards_import, :with_files, courtesy_notification: :not_required)
    attachment = import.files.first

    described_class.new.perform(attachment)

    source_file = SourceFile.last
    expect(source_file).to be_courtesy_notification_not_required
  end

  it "publishes error message if creating import record fails" do
    import = create(:standards_import, :with_files)
    error = StandardError.new("some error")
    allow(SourceFile).to receive(:create_with).and_raise(error)
    attachment = import.files.first

    expect_any_instance_of(ErrorSubscriber).to receive(:report).and_call_original
    expect {
      described_class.new.perform(attachment)
    }.to_not change(SourceFile, :count)
  end

  it "links a new pdf source file to its original docx version" do
    perform_enqueued_jobs do
      allow(DocToPdfConverter).to receive(:convert).and_return(nil)

      docx_file = file_fixture("document.docx")
      pdf_file = file_fixture("pixel1x1.pdf")
      import = create(:standards_import, files: [docx_file, pdf_file], courtesy_notification: :pending, name: "Mickey", email: "mouse@example.com")
      docx = import.source_files.find(&:docx?)
      pdf = import.source_files.find(&:pdf?)
      docx.update!(link_to_pdf_filename: "pixel1x1.pdf")
      attachment = pdf.active_storage_attachment
      pdf.destroy # so we can pretend we're creating it for the first time

      described_class.new.perform(attachment)

      expect(import.reload.source_files.size).to eql(2)
      expect(docx.reload).to have_attributes(
        status: "archived",
        link_to_pdf_filename: nil,
        courtesy_notification: "not_required"
      )
      pdf = import.source_files.find(&:pdf?)
      expect(pdf.original_source_file_id).to eql(docx.id)
    end
  end
end
