# frozen_string_literal: true

module Helpers
  module StubFeatureFlags
    # Enable/disable flipper for a specific feature for any actors
    # stub_feature_flag(:staff_directory, true)
    def stub_feature_flag(feature_name, value)
      allow(Flipper).to receive(:enabled?).with(feature_name, anything).and_return(value)
      allow(Flipper).to receive(:enabled?).with(feature_name).and_return(value)
    end
  end
end
