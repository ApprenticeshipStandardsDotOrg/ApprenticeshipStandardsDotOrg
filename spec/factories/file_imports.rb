FactoryBot.define do
  factory :file_import do
    active_storage_attachment { ActiveStorage::Attachment.new }
  end
end
