FactoryBot.define do
  factory :organization do
    sequence(:title) { |n| "Computer Academy #{n}" }
  end
end
