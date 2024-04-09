FactoryBot.define do
  factory :registration_agency do
    traits_for_enum :agency_type, RegistrationAgency.agency_types

    agency_type { :oa }
    state {
      if for_state_abbreviation
        build(:state, abbreviation: for_state_abbreviation)
      else
        build(:state)
      end
    }

    transient do
      for_state_abbreviation { nil }
    end

    trait :for_national_program do
      state { nil }
    end
  end
end
