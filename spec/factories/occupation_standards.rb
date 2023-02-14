FactoryBot.define do
  factory :occupation_standard do
    title { "Mechanic" }
    occupation
    url { "http://example.com" }
    registration_agency
  end
end
