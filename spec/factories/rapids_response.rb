FactoryBot.define do
  factory :rapids_response, class: Hash do
    skip_create
    totalCount { 645 }
    wps { [] }

    transient do
      with_occupation_standards { 0 }
      occupation_type { %w[hybrid time competency].sample }
    end

    after(:create) do |rapids_response, context|
      if context.with_occupation_standards.positive?
        rapids_response["wps"] = create_list(:rapids_api_occupation_standard,
          context.with_occupation_standards,
          context.occupation_type)
      end
    end

    initialize_with { attributes.stringify_keys }
  end
end
