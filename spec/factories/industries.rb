FactoryBot.define do
  factory :industry do
    name { "Healthcare Support Occupations" }
    version { Industry::CURRENT_VERSION }
    sequence(:prefix) { |n| n.to_s }
  end
end
