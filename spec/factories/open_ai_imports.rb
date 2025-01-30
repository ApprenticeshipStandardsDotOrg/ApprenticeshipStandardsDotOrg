FactoryBot.define do
  factory :open_ai_import do
    occupation_standard
    response { "{}" }
  end

  trait :with_pdf_import do
    import { create(:imports_pdf) }
  end
end
