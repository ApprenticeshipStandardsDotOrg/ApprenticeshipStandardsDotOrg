class APIKey < ApplicationRecord
  belongs_to :user

  def token
    APIBearerToken.create(user: user, api_key_id: id).jwt_token
  end
end
