FactoryBot.define do
  factory :source_file do
    traits_for_enum :status, SourceFile.statuses

    initialize_with do
      standards_import = create(:standards_import, :with_files)
      SourceFile.where(
        active_storage_attachment: standards_import.files.first
      ).first
    end
  end
end
