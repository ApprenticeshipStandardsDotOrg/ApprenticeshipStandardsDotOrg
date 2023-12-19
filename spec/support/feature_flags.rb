require "./spec/support/helpers/stub_feature_flags"

RSpec.configure do |config|
  config.before(:suite) do
    Flipper.add(:recaptcha)
    Flipper.add(:show_recently_added_section)
    Flipper.add(:similar_programs_elasticsearch)
    Flipper.add(:use_elasticsearch_for_search)
  end

  config.include Helpers::StubFeatureFlags
end
