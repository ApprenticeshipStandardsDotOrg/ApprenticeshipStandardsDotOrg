FactoryBot.define do
  factory :related_instruction do
    title { "MyString" }
    hours { "" }
    elective { false }
    sort_order { 1 }
    occupation_standard { nil }
    default_course_id { 1 }
  end
end
