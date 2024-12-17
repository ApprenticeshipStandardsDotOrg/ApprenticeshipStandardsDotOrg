FactoryBot.define do
  factory :occupation_standard do
    traits_for_enum :national_standard_type, OccupationStandard.national_standard_types

    title { "Mechanic" }
    occupation
    url { "http://example.com" }
    ojt_type { :hybrid }
    registration_agency

    trait :with_work_processes do
      work_processes { build_list(:work_process, 1) }
    end

    trait :with_work_processes_and_competencies do
      work_processes { build_list(:work_process, 1, :with_competencies) }
    end

    trait :state_standard do
      national_standard_type { nil }
    end

    trait :with_data_import do
      after :create do |occupation_standard|
        import = build(:imports_pdf)
        create(:data_import, import: import, occupation_standard: occupation_standard)
      end
    end

    trait :with_redacted_document do
      redacted_document { Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "pixel1x1.pdf"), "application/pdf") }
    end
  end
end
