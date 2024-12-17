FactoryBot.define do
  factory :work_process do
    sequence(:title) { |n| "Work Process ##{n}" }
    description { "Work Process Description" }
    occupation_standard

    trait :with_competencies do
      competencies { build_list(:competency, 1) }
    end
  end
end
