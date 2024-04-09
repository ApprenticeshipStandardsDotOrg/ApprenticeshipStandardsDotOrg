FactoryBot.define do
  factory :registration_agency do
    traits_for_enum :agency_type, RegistrationAgency.agency_types

    agency_type { :oa }

    trait :for_national_program do
      state { nil }
    end

    transient do
      for_state_abbreviation { nil }
    end

    after(:build) do |registration_agency, context|
      registration_agency.state ||= if (context.for_state_abbreviation)
        FactoryBot.build(:state, abbreviation: context.for_state_abbreviation)
      else
        FactoryBot.build(:state)
      end
    end
  end
end
