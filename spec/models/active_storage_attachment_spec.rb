require "rails_helper"

RSpec.describe ActiveStorage::Attachment, type: :model do
  it "has a valid factory" do
    attachment = build(:active_storage_attachment)

    expect(attachment).to be_valid
  end

  it "creates a file import record when type is standards import" do
    import = create(:standards_import)
    attachment = build(:active_storage_attachment, record: import)

    expect { attachment.save! }.to change(SourceFile, :count).by(1)

    source_file = SourceFile.last
    expect(source_file.active_storage_attachment).to eq attachment
  end

  it "publishes error message if creating import record fails" do
    import = create(:standards_import)
    attachment = build(:active_storage_attachment, record: import)
    error = StandardError.new("some error")
    allow(SourceFile).to receive(:create!).and_raise(error)

    expect_any_instance_of(ErrorSubscriber).to receive(:report).and_call_original
    expect { attachment.save! }.to_not change(SourceFile, :count)
  end

  it "does not create a file import record when type is not standards import" do
    user = create(:user)
    attachment = build(:active_storage_attachment, record: user)

    expect { attachment.save! }.to_not change(SourceFile, :count)
  end

  it "deletes file import record when deleted" do
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
