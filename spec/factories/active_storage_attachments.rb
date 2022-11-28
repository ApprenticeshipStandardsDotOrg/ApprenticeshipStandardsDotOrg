FactoryBot.define do
  factory :active_storage_attachment, class: "ActiveStorage::Attachment" do
    name { "abc" }
    association :record, factory: :standards_import
    association :blob, factory: :active_storage_blob
    content_type { "image/jpeg" }
  end
end