FactoryBot.define do
  factory :data_import do
    user
    occupation_standard
    file_import
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "occupation-standards-template.xlsx"), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") }

    trait :unprocessed do
      occupation_standard { nil }
    end

    factory :data_import_for_hybrid do
      file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "comp-occupation-standards-template.xlsx"), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") }
    end
  end
end
