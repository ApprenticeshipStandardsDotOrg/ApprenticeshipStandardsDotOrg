FactoryBot.define do
  factory :source_file do
    traits_for_enum :status, SourceFile.statuses

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
        standards_import = create(:standards_import, :with_pdf_file_with_attachments)
        SourceFile.where(
          active_storage_attachment: standards_import.files.first
        ).first
      end
    end
  end
end
