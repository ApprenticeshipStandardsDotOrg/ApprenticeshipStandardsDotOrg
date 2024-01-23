FactoryBot.define do
  factory :source_file do
    traits_for_enum :status, SourceFile.statuses

    trait :with_redacted_file do
      redacted_source_file do
        Rack::Test::UploadedFile.new(
          Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf"),
          "application/pdf"
        )
      end
    end

    initialize_with do
      standards_import = create(:standards_import, :with_files)
      SourceFile.where(
        active_storage_attachment: standards_import.files.first
      ).first
    end

    trait :with_docx_attachment do
      initialize_with do
        standards_import = create(:standards_import, :with_docx_file_with_attachments)
        SourceFile.where(
          active_storage_attachment: standards_import.files.first
        ).first
      end
    end

    trait :with_pdf_attachment do
      initialize_with do
        standards_import = create(:standards_import, :with_pdf_file)
        SourceFile.where(
          active_storage_attachment: standards_import.files.first
        ).first
      end
    end

    trait :without_redacted_source_file do
      redacted_source_file { nil }
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
