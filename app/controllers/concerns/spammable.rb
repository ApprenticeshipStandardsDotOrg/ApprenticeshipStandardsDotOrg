module Spammable
  extend ActiveSupport::Concern

  VALID_RECAPTCHA_SCORE = 0.5

  included do
    before_action :verify_recaptcha, only: :create
  end

  private

  def verify_recaptcha
    return if skip_recaptcha?

    uri = URI("https://www.google.com/recaptcha/api/siteverify")
    resp = Net::HTTP.post_form(
      uri,
      secret: ENV["GOOGLE_RECAPTCHA_SECRET_KEY"],
      response: params["g-recaptcha-response"],
      remoteip: request.remote_ip
    )
    parsed_json = JSON.parse(resp.body)
    success = parsed_json["success"]
    score = parsed_json["score"].to_f

    unless success
      Rails.error.report(
        CaptchaError.new("Error with Google reCAPTCHA"),
        context: parsed_json,
        handled: true
      )
    end

    if !success || score < VALID_RECAPTCHA_SCORE
      redirect_to guest_root_path
    end
  end

  def skip_recaptcha?
    current_user&.admin? || !Flipper.enabled?(:recaptcha)
  end

  class CaptchaError < StandardError; end
end
