FactoryBot.define do
  factory :source_file do
    traits_for_enum :status, SourceFile.statuses

    transient do
      standards_import { create(:standards_import, :with_files) }
    end

    active_storage_attachment_id { standards_import.files.first.id }

    to_create { |_obj, _context| SourceFile.last }
  end
end
