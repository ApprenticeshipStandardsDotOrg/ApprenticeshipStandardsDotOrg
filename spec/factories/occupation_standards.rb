FactoryBot.define do
  factory :occupation_standard do
    traits_for_enum :national_standard_type, OccupationStandard.national_standard_types

    title { "Mechanic" }
    occupation
    url { "http://example.com" }
    registration_agency

    trait :state_standard do
      national_standard_type { nil }
    end
  end
end
