FactoryBot.define do
  factory :word_replacement do
    word { "Slur" }
    replacement { "****" }
  end
end
