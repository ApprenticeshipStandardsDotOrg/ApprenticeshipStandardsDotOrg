FactoryBot.define do
  factory :competency do
    work_process
    title { "Competency" }
    description { "Competency Description" }
    sequence(:sort_order) { |n| n }
  end
end
