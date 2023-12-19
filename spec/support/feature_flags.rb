require "./spec/support/helpers/stub_feature_flags"

RSpec.configure do |config|
  config.before(:suite) do
    Flipper.add(:use_elasticsearch_for_search)
    Flipper.add(:show_recently_added_section)
  end

  config.include Helpers::StubFeatureFlags
end
