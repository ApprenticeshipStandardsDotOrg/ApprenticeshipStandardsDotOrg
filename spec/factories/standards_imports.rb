FactoryBot.define do
  factory :standards_import do
    name { "Harry Potter" }
    email { "foo@example.com" }

    trait :with_files do
      files { [Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf"), "application/pdf")] }
    end

    to_create do |obj, _context|
      obj.save!
      CreateSourceFilesJob.perform_now(obj)
    end
  end
end
