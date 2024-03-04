FactoryBot.define do
  factory :rapids_response, class: Hash do
    skip_create
    totalCount { 645 }
    wps { [] }

    transient do
      with_work_processes { 0 }
    end

    after(:create) do |rapids_response, context|
      if context.with_work_processes.positive?
        work_process["wps"] = create_list(:rapids_api_occupation_standard,
          context.with_work_processes,
          contrxt.occupation_type)
      end
    end

    initialize_with { attributes.stringify_keys }
  end
end

FactoryBot.define do
  factory :rapids_api_detailed_work_activity, class: Hash do
    skip_create

    sequence(:title) { |n| "Detailed Work Activity #{n}" }
    sequence(:task) { |n| ["Task #{n}"] }

    initialize_with { attributes.stringify_keys }
  end
end
