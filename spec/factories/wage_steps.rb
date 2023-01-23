FactoryBot.define do
  factory :wage_step do
    occupation_standard
    sort_order { 1 }
    title { "1st 12 months" }
    minimum_hours { 120 }
    ojt_percentage { "20.00" }
    duration_in_months { 12 }
  end
end
