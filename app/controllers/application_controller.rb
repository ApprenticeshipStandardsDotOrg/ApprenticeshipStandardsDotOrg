class ApplicationController < ActionController::Base
  before_action :authenticate, if: :staging?

  include ActiveStorage::SetCurrent
  include Pagy::Backend

  private

  def staging?
    ENV.fetch("APP_ENVIRONMENT", Rails.env) == "staging"
  end

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV.fetch("BASIC_AUTH_USERNAME", nil) &&
        password == ENV.fetch("BASIC_AUTH_PASSWORD", nil)
    end
  end
end
