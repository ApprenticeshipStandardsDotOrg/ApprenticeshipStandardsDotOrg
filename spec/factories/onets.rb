FactoryBot.define do
  factory :onet do
    title { "Actors" }
    code { "27-2011.00" }
    version { Onet::CURRENT_VERSION }
  end
end
