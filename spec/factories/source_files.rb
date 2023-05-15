FactoryBot.define do
  factory :source_file do
    traits_for_enum :status, SourceFile.statuses

    association :active_storage_attachment, factory: :active_storage_attachment_without_callback
  end
end
