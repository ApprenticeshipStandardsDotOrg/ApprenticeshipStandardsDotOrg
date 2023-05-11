FactoryBot.define do
  factory :work_process do
    sequence(:title) { |n| "Work Process ##{n}" }
    description { "Work Process Description" }
    occupation_standard
  end
end
