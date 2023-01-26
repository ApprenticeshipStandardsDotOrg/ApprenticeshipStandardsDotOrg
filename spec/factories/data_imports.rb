FactoryBot.define do
  factory :data_import do
    description { "Here is a description" }
    user
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "occupation-standards-template.xlsx"), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") }
  end
end
