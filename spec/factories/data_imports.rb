FactoryBot.define do
  factory :data_import do
    description { "Here is a description" }
    user
    file { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "pixel1x1.jpg"), "image/jpeg") }
  end
end
