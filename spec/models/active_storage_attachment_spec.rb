require "rails_helper"

RSpec.describe ActiveStorage::Attachment, type: :model do
  it "creates a source file record when type is standards import" do
    import = build(:standards_import, :with_files)

    expect { import.save! }.to change(SourceFile, :count).by(1)

    source_file = SourceFile.last
    expect(source_file.active_storage_attachment).to eq import.files.first
  end

  it "publishes error message if creating import record fails" do
    import = build(:standards_import, :with_files)
    error = StandardError.new("some error")
    allow_any_instance_of(ActiveStorage::Attachment).to receive(:create_source_file!).and_raise(error)

    expect_any_instance_of(ErrorSubscriber).to receive(:report).and_call_original
    expect { import.save! }.to_not change(SourceFile, :count)
  end

  it "does not create a source file record when type is not standards import" do
    occupation_standard = build(:occupation_standard, :with_redacted_document)

    expect { occupation_standard.save! }.to_not change(SourceFile, :count)
  end

  it "deletes source file record when deleted" do
    source_file = create(:source_file)
    attachment = source_file.active_storage_attachment

    expect {
      attachment.destroy!
    }.to change(ActiveStorage::Attachment, :count).by(-1)
      .and change(SourceFile, :count).by(-1)

    expect { attachment.reload }.to raise_error(ActiveRecord::RecordNotFound)
    expect { source_file.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
