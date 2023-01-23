FactoryBot.define do
  factory :competency do
    work_process
    title { "Competency" }
    description { "Competency Description" }
    sort_order { 1 }
  end
end
