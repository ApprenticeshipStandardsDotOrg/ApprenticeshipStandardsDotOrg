require "rails_helper"

RSpec.describe ActiveStorage::Attachment, type: :model do
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
