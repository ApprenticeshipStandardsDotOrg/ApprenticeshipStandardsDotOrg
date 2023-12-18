require "./spec/support/helpers/stub_feature_flags"

RSpec.configure do |config|
  config.before(:suite) do
    Flipper.add(:use_elasticsearch_for_search)
  end

  config.include Helpers::StubFeatureFlags
end
