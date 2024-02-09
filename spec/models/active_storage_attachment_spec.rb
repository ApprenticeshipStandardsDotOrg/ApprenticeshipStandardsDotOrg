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

  describe "#has_linked_original_file?" do
    it "is true if source file has original_source_file present" do
      original_source_file = create(:source_file)
      source_file = create(:source_file)
      source_file.update!(original_source_file: original_source_file)
      attachment = source_file.active_storage_attachment

      expect(attachment).to have_linked_original_file
    end

    it "is false if source file does not have original_source_file present" do
      source_file = create(:source_file)
      attachment = source_file.active_storage_attachment

      expect(attachment).to_not have_linked_original_file
    end
  end
end
