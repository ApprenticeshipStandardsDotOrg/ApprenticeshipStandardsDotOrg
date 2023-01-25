FactoryBot.define do
  factory :occupation_standard do
    occupation
    url { "http://example.com" }
    registration_agency
  end
end
