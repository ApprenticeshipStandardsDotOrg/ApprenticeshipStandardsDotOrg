FactoryBot.define do
  factory :source_file do
    initialize_with do
      standards_import = create(:standards_import, :with_files)
      CreateSourceFileJob.perform_now(standards_import.files.first)
      SourceFile.where(
        active_storage_attachment: standards_import.files.first
      ).first
    end

    traits_for_enum :status, SourceFile.statuses

    trait :doc do
      initialize_with do
        standards_import = create(:standards_import, :with_doc_file)
        CreateSourceFileJob.perform_now(standards_import.files.first)
        SourceFile.where(
          active_storage_attachment: standards_import.files.first
        ).first
      end
    end

    trait :docx do
      initialize_with do
        standards_import = create(:standards_import, :with_docx_file)
        CreateSourceFileJob.perform_now(standards_import.files.first)
        SourceFile.where(
          active_storage_attachment: standards_import.files.first
        ).first
      end
    end

    trait :docx_with_attachments do
      initialize_with do
        standards_import = create(:standards_import, :with_docx_file_with_attachments)
        CreateSourceFileJob.perform_now(standards_import.files.first)
        SourceFile.where(
          active_storage_attachment: standards_import.files.first
        ).first
      end
    end

    trait :pdf do
      initialize_with do
        standards_import = create(:standards_import, :with_pdf_file)
        CreateSourceFileJob.perform_now(standards_import.files.first)
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
      redacted_at { Time.current }
    end

    trait :bulletin do
      initialize_with do
        standards_import = create(:standards_import, :with_docx_file, bulletin: true)
        CreateSourceFileJob.perform_now(standards_import.files.first)
        SourceFile.where(
          active_storage_attachment: standards_import.files.first
        ).first
      end
    end
  end
end
