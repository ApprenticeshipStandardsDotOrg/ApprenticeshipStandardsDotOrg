FactoryBot.define do
  factory :industry do
    name { "Healthcare Support Occupations" }
    version { Industry::CURRENT_VERSION }
    prefix { "31" }
  end
end
