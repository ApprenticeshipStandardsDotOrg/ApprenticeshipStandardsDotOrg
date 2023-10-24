FactoryBot.define do
  factory :onet do
    title { "Actors" }
    sequence(:code) { |n| "27-2011.#{n}" }
    version { Onet::CURRENT_VERSION }
  end
end
