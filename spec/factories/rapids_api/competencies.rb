FactoryBot.define do
  factory :rapids_api_competency, class: Hash do
    skip_create

    sequence(:title) { |n| "Competency #{n}" }

    initialize_with { attributes.stringify_keys }
  end
end
