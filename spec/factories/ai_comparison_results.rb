FactoryBot.define do
  factory :ai_comparison_result do
    occupation_standard
    work_processes_score { 85.0 }
    related_instructions_score { 90.0 }
    overall_score { 87.0 }
    needs_review { false }
    flagged_by_system { false }
    flagged_by_user { false }

    trait :low_score do
      work_processes_score { 60.0 }
      related_instructions_score { 65.0 }
      overall_score { 62.0 }
      flagged_by_system { true }
      needs_review { true }
    end

    trait :flagged_by_user do
      flagged_by_user { true }
      needs_review { true }
    end
  end
end
