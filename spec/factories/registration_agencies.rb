FactoryBot.define do
  factory :registration_agency do
    traits_for_enum :agency_type, RegistrationAgency.agency_types

    state
    agency_type { :oa }

    trait :for_national_program do
      state { nil }
    end
  end
end
