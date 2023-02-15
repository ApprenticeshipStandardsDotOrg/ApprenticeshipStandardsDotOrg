FactoryBot.define do
  factory :data_import do
    description { "Here is a description" }
    user
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "occupation-standards-template.xlsx"), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") }

    factory :data_import_for_hybrid do
      description { "Here is a description for this Hybrid w/ Max + Min Hours" }
      file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "comp-occupation-standards-template.xlsx"), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") }
    end
  end
end
