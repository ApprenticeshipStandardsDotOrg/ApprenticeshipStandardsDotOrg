FactoryBot.define do
  factory :source_file do
    association :active_storage_attachment, factory: :active_storage_attachment_without_callback
  end
end
