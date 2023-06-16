FactoryBot.define do
  factory :active_storage_attachment, class: "ActiveStorage::Attachment" do
    name { "abc999" }
    association :record, factory: :standards_import
    association :blob, factory: :active_storage_blob
    content_type { "image/jpeg" }

    factory :active_storage_attachment_without_callback do
      before(:create) do |attachment|
        class << attachment
          def create_source_file
          end
        end
      end
    end
  end
end
