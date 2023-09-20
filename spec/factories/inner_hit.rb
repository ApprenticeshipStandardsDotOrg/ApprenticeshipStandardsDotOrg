FactoryBot.define do
  factory :inner_hit do
    sequence(:id)
    sequence(:title) { |n| "Inner hit #{n}" }

    initialize_with { new(**attributes) }
  end
end
