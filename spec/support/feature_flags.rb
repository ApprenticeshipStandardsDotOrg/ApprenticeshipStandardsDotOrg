require "./spec/support/helpers/stub_feature_flags"

RSpec.configure do |config|
  config.include Helpers::StubFeatureFlags
end
