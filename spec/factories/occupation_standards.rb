FactoryBot.define do
  factory :occupation_standard do
    data_import
    title { "Mechanic" }
    occupation
    url { "http://example.com" }
    registration_agency
  end
end
