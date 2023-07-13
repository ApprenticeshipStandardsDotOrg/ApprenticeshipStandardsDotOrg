# frozen_string_literal: true

module Helpers
  module WebmockHelpers
    def stub_recaptcha_high_score
      stub_const "ENV", ENV.to_h.merge("ENABLE_RECAPTCHA" => "true")
      stub_request(:post, /google.*recaptcha/)
        .to_return(status: 200, body: {
          success: true,
          challenge_ts: "2023-07-07T19:40:09Z",
          hostname: "apprenticeshipstandards.org",
          score: 0.9,
          action: "submit"
        }.to_json, headers: {})
    end

    def stub_recaptcha_low_score
      stub_const "ENV", ENV.to_h.merge("ENABLE_RECAPTCHA" => "true")
      stub_request(:post, /google.*recaptcha/)
        .to_return(status: 200, body: {
          success: true,
          challenge_ts: "2023-07-07T19:40:09Z",
          hostname: "apprenticeshipstandards.org",
          score: 0.2,
          action: "submit"
        }.to_json, headers: {})
    end

    def stub_recaptcha_failure
      stub_const "ENV", ENV.to_h.merge("ENABLE_RECAPTCHA" => "true")
      stub_request(:post, /google.*recaptcha/)
        .to_return(status: 200, body: {
          success: false,
          challenge_ts: "2023-07-07T19:40:09Z",
          hostname: "apprenticeshipstandards.org",
          error_codes: ["missing-input-secret"],
          action: "submit"
        }.to_json, headers: {})
    end
  end
end
