FactoryBot.define do
  factory :source_file do
    traits_for_enum :status, SourceFile.statuses

    initialize_with do
      standards_import = create(:standards_import, :with_files)
      SourceFile.where(
        active_storage_attachment: standards_import.files.first
      ).first
    end

    trait :with_redacted_source_file do
      redacted_source_file {
        Rack::Test::UploadedFile.new(
          Rails.root.join(
            "spec", "fixtures", "files", "pixel1x1_redacted.pdf"
          )
        )
      }
    end
  end
end
