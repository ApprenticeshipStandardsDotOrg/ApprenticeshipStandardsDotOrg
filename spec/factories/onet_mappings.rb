FactoryBot.define do
  factory :onet_mapping do
    onet
    association :next_version_onet, factory: :onet
  end
end
