FactoryBot.define do
  factory :standards_import do
    trait :with_files do
      files { [Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf"), "application/pdf")] }
    end

    trait :with_docx_file_with_attachments do
      files { [Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "docx_file_attachments.docx"))] }
    end

    trait :with_pdf_file do
      files { [Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf"))] }
    end

    to_create do |obj, _context|
      obj.save!
      CreateSourceFilesJob.perform_now(obj)
    end
  end
end
