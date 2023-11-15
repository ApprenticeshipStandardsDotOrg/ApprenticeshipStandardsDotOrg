FactoryBot.define do
  factory :source_file do
    traits_for_enum :status, SourceFile.statuses

    active_storage_attachment { build(:active_storage_attachment, source_file: instance) }
  end
end
