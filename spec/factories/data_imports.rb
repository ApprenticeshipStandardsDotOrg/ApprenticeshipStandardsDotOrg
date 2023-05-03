FactoryBot.define do
  factory :data_import do
    user
    occupation_standard
    source_file
    status { :completed }
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "occupation-standards-template.xlsx"), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") }

    trait :pending do
      status { :pending }
      occupation_standard { nil }
    end

    trait :hybrid do
      file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "comp-occupation-standards-template.xlsx"), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") }
    end

    trait :no_rapids do
      file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "occupation-standards-no-rapids-template.xlsx"), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") }
    end

    trait :no_onet do
      file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "occupation-standards-no-onet-template.xlsx"), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") }
    end
  end
end
