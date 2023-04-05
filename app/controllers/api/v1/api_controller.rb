class API::V1::APIController < ApplicationController
  include JSONAPI::ActsAsResourceController

  protect_from_forgery with: :null_session

  before_action :authenticate

  rescue_from JWT::DecodeError, with: :unable_to_authenticate

  private

  def authenticate
    authenticate_with_http_token do |token, options|
      api_bearer_token = APIBearerToken.new(token)
      if api_bearer_token.user_id
        api_key_id = api_bearer_token.api_key_id
        @user = User
          .joins(:api_keys)
          .where(
            users: {id: api_bearer_token.user_id},
            api_keys: {id: api_key_id}
          )
          .first
      end
    end

    unless @user
      head :unauthorized
      nil
    end
  end

  def unable_to_authenticate
    head :unauthorized
  end
end
