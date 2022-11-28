FactoryBot.define do
  factory :file_import do
    association :active_storage_attachment, factory: :active_storage_attachment
  end
end
