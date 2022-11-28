FactoryBot.define do
  factory :standards_import do
    trait :with_files do
      files { [Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "pixel1x1.jpg"), "image/jpeg")]  }
    end
  end
end
