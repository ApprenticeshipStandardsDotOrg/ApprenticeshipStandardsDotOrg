FactoryBot.define do
  factory :rapids_api_detailed_work_activity, class: Hash do
    skip_create

    sequence(:title) { |n| "Detailed Work Activity #{n}" }
    sequence(:task) { |n| ["Task #{n}"] }

    initialize_with { attributes.stringify_keys }
  end
end
