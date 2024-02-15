FactoryBot.define do
  factory :rapids_response, class: Hash do
    skip_create
    totalCount { 645 }
    wps { [] }

    transient do
      with_work_processes { 0 }
    end

    after(:create) do |work_process, context|
      if context.with_work_processes.positive?
        work_process["wps"] = create_list(:rapids_api_work_process,
                                                  context.with_work_processes,
                                                  with_detailed_work_activities: 2
                                                 )
      end
    end

    initialize_with { attributes.stringify_keys }
  end
end

FactoryBot.define do
  factory :rapids_api_detailed_work_activity, class: Hash do
    skip_create

    sequence(:title) { |n| "Detailed Work Activity #{n}"}
    sequence(:task) { |n| ["Task #{n}"] }

    initialize_with { attributes.stringify_keys }
  end
end

FactoryBot.define do
  factory :rapids_api_work_process, class: Hash do
    skip_create

    sponsorName { "Sponsor RTI Provider" }
    sponsorNumber { "2024-MI-136422" }
    occupationTitle { "ALARM  OPERATOR (Gov Serv) (0870CBV1)" }
    onetSocCode { "43-5031.00" }
    rapidsCode { "0870CB" }
    occType { "Competency-Based" }
    jobDesc { "Operate telephone, radio, or other communication systems to receive and communicate requests for emergency assistance at 9-1-1 public safety answering points and emergency operations centers. Take information from the public and other sources regarding crimes, threats, disturbances, acts of terrorism, fires, medical emergencies, and other public safety matters. May coordinate and provide information to law enforcement and emergency response personnel. May access sensitive databases and other information sources as needed. May provide additional instructions to callers based on knowledge of and certification in law enforcement, fire, or emergency medical procedures." }
    jobZone { "Job Zone Two: Some Preparation Needed. These occupations often involve using your knowledge and skills to help others. Examples include orderlies, counter and rental clerks, customer service representatives, security guards, upholsterers, tellers, and dental laboratory technicians." }
    isWPSUploaded { false }
    wpsDocument { "https://dolstage.appiancloud.com/suite/webapi/rapids/data-sharing/documents/wps/145973" }
    dwas { [] }

    transient do
      with_detailed_work_activities { 0 }
    end

    after(:create) do |work_process, context|
      if context.with_detailed_work_activities.positive?
        work_process["dwas"] = create_list(:rapids_api_detailed_work_activity,
                                                  context.with_detailed_work_activities
                                                 )
      end
    end

    initialize_with { attributes.stringify_keys }
  end
end
