FactoryBot.define do
  factory :rapids_api_detailed_work_activity, class: Hash do
    skip_create

    sequence(:title) { |n| "Detailed Work Activity #{n}" }
    sequence(:tasks) { |n| [""] }

    initialize_with { attributes.stringify_keys }

    transient do
      with_tasks { 0 }
    end

    after(:create) do |detailed_work_activity, context|
      if context.with_tasks.positive?
        detailed_work_activity["tasks"] = [
          (1..context.with_tasks).map do |n|
            "Competency #{n}"
          end.to_sentence(words_connector: "; ", two_words_connector: "; ", last_word_connector: "; ")
        ]
      end
    end

    factory :rapids_api_detailed_work_activity_for_hybrid do
      minHours { 200 }
      maxHours { 2000 }
    end

    factory :rapids_api_detailed_work_activity_for_time_based do
      minHours { 200 }
    end

    factory :rapids_api_detailed_work_activity_for_competency_based do
    end
  end
end
