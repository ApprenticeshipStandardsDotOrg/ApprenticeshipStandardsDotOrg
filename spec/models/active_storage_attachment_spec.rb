require "rails_helper"

RSpec.describe ActiveStorage::Attachment, type: :model do
  it "has a valid factory" do
    attachment = build(:active_storage_attachment)

    expect(attachment).to be_valid
  end

  it "creates a file import record when type is standards import" do
    import = create(:standards_import)
    attachment = build(:active_storage_attachment, record: import)

    expect { attachment.save! }.to change(FileImport, :count).by(1)

    file_import = FileImport.last
    expect(file_import.active_storage_attachment).to eq attachment
  end

  it "does not create a file import record when type is not standards import" do
    user = create(:user)
    attachment = build(:active_storage_attachment, record: user)

    expect { attachment.save! }.to_not change(FileImport, :count)
  end
end
