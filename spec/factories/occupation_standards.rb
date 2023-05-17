FactoryBot.define do
  factory :occupation_standard do
    traits_for_enum :national_standard_type, OccupationStandard.national_standard_types

    title { "Mechanic" }
    occupation
    url { "http://example.com" }
    ojt_type { :hybrid }
    registration_agency

    trait :state_standard do
      national_standard_type { nil }
    end

    trait :with_data_import do
      after :create do |occupation_standard|
        create(:data_import, occupation_standard: occupation_standard)
      end
    end

    trait :with_redacted_document do
      redacted_document { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf"), "application/pdf") }
    end
  end
end
