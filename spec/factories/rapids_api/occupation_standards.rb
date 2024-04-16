FactoryBot.define do
  factory :rapids_api_occupation_standard, class: Hash do
    skip_create

    sponsorName { "Sponsor RTI Provider" }
    sponsorNumber { "2024-MI-136422" }
    sequence(:occupationTitle) { |n| "ALARM OPERATOR (Gov Serv) (0870CBV1) #{n}" }
    onetSocCode { "43-5031.00" }
    rapidsCode { "0870" }
    jobDesc { "Operate telephone, radio, or other communication systems to receive and communicate requests for emergency assistance at 9-1-1." }
    jobZone { "Job Zone Two: Some Preparation Needed." }
    isWPSUploaded { false }
    sequence(:wpsDocument) { |n| "https://entbpmpstg.dol.gov/suite/webapi/rapids/data-sharing/documents/wps/#{n}" }
    dwas { [] }

    transient do
      with_detailed_work_activities { 0 }
    end

    after(:create) do |occupation_standard, context|
      if context.with_detailed_work_activities.positive?
        occupation_standard["dwas"] =
          case occupation_standard["occType"]
          when "Hybrid"
            create_list(
              :rapids_api_detailed_work_activity_for_hybrid,
              context.with_detailed_work_activities,
              with_tasks: 1
            )
          when "Time-Based"
            create_list(
              :rapids_api_detailed_work_activity_for_time_based,
              context.with_detailed_work_activities,
              with_tasks: 1
            )
          when "Competency-Based"
            create_list(
              :rapids_api_detailed_work_activity_for_competency_based,
              context.with_detailed_work_activities,
              with_tasks: 1
            )
          end
      end
    end

    trait :hybrid do
      occType { "Hybrid" }
    end

    trait :time do
      occType { "Time-Based" }
    end

    trait :competency do
      occType { "Competency-Based" }
    end

    trait :with_wps_document do
      isWPSUploaded { true }
    end

    initialize_with { attributes.stringify_keys }
  end
end
