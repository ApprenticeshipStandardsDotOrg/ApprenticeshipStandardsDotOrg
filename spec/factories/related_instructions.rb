FactoryBot.define do
  factory :related_instruction do
    title { "Computerized Techniques" }
    hours { 60 }
    elective { false }
    sort_order { 1 }
    occupation_standard
    association :default_course, factory: :course
  end
end
