FactoryBot.define do
  factory :rapids_api_work_process, class: Hash do
    skip_create

    sequence(:title) { |n| "Work Process #{n}" }

    trait :with_min_hours do
      minHours { 20 }
    end

    trait :with_max_hours do
      maxHours { 200 }
    end

    initialize_with { attributes.stringify_keys }
  end
end
