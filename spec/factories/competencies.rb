FactoryBot.define do
  factory :competency do
    work_process
    title { "Competency Title" }
    description { "Competency Description" }
    sequence(:sort_order) { |n| n }
  end
end
