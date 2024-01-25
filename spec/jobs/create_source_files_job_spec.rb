require "rails_helper"

RSpec.describe CreateSourceFilesJob, "#perform", type: :job do
  it "creates source file records" do
    file1 = file_fixture("pixel1x1.pdf")
    file2 = file_fixture("pixel1x1.jpg")
    import = create(:standards_import, files: [file1, file2])
    SourceFile.destroy_all # Remove source files created from factory

    expect {
      described_class.new.perform(import)
    }.to change(SourceFile, :count).by(2)

    source_file1 = SourceFile.first
    source_file2 = SourceFile.last
    expect(source_file1.active_storage_attachment).to eq import.files.first
    expect(source_file2.active_storage_attachment).to eq import.files.last
  end

  it "marks source_file courtesy_notification as pending if import courtesy notification is pending" do
    import = create(:standards_import, :with_files, email: "foo@example.com", name: "Foo", courtesy_notification: :pending)
    SourceFile.destroy_all # Remove source files created from factory

    described_class.new.perform(import)

    source_file = SourceFile.last
    expect(source_file).to be_courtesy_notification_pending
  end

  it "does not mark source_file courtesy_notification as pending if import courtesy notification is not_required" do
    import = create(:standards_import, :with_files, courtesy_notification: :not_required)
    SourceFile.destroy_all # Remove source files created from factory

    described_class.new.perform(import)

    source_file = SourceFile.last
    expect(source_file).to be_courtesy_notification_not_required
  end

  it "publishes error message if creating import record fails" do
    import = create(:standards_import, :with_files)
    SourceFile.destroy_all # Remove source files created from factory
    error = StandardError.new("some error")
    allow(SourceFile).to receive(:create_with).and_raise(error)

    expect_any_instance_of(ErrorSubscriber).to receive(:report).and_call_original
    expect {
      described_class.new.perform(import)
    }.to_not change(SourceFile, :count)
  end

  it "links a new pdf source file to its original docx version" do
    docx_file = file_fixture("document.docx")
    pdf_file = file_fixture("pixel1x1.pdf")
    import = create(:standards_import, files: [docx_file, pdf_file])
    docx = import.source_files.find(&:docx?)
    pdf = import.source_files.find(&:pdf?)
    docx.update!(link_to_pdf_filename: "pixel1x1.pdf")
    pdf.destroy # so we can pretend we're creating it for the first time

    described_class.new.perform(import)

    expect(import.reload.source_files.size).to eql(2)
    expect(docx.reload).to have_attributes(
      status: "archived",
      link_to_pdf_filename: nil
    )
    pdf = import.source_files.find(&:pdf?)
    expect(pdf.original_source_file_id).to eql(docx.id)
  end
end
