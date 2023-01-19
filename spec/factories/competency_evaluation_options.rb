FactoryBot.define do
  factory :competency_evaluation_option do
    title { "MyString" }
    sort_order { 1 }
    association :resource, factory: :occupation
  end
end
