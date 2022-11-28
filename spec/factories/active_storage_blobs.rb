FactoryBot.define do
  factory :active_storage_blob, class: "ActiveStorage::Blob" do
    key { "abc" }
    filename { "abc" }
    service_name { :local }
    byte_size { 1 }
    checksum { "abc" }
  end
end