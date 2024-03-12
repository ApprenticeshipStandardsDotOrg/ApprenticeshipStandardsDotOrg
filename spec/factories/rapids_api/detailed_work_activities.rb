FactoryBot.define do
  factory :rapids_api_detailed_work_activity, class: Hash do
    skip_create

    sequence(:title) { |n| "Detailed Work Activity #{n}" }
    sequence(:task) { |n| ["Task #{n}"] }

    initialize_with { attributes.stringify_keys }

    factory :rapids_api_detailed_work_activity_for_hybrid do
      minHours { 200 }
      maxHours { 2000 }
    end

    factory :rapids_api_detailed_work_activity_for_time_based do
      minHours { 200 }
    end

    factory :rapids_api_detailed_work_activity_for_competency_based do
    end
  end
end
