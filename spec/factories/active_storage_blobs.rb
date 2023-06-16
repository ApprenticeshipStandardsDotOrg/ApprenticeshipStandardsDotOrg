FactoryBot.define do
  factory :active_storage_blob, class: "ActiveStorage::Blob", aliases: [:blob] do
    sequence(:key) { |n| "abc#{n}999" }
    filename { "abc" }
    service_name { :local }
    byte_size { 1 }
    checksum { "abc" }
  end
end
