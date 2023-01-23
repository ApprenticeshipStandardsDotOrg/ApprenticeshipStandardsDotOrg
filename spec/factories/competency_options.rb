FactoryBot.define do
  factory :competency_option do
    title { "Competency Title" }
    sort_order { 1 }

    trait :for_occupation do
      association :resource, factory: :occupation
    end

    trait :for_competency do
      association :resource, factory: :competency
    end
  end
end
