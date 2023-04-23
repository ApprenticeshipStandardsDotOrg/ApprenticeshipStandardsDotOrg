class APIKeyPolicy < AdminPolicy
  attr_reader :user, :api_key

  def initialize(user, api_key)
    @user = user
    @api_key = api_key
  end
end
