class APIBearerToken < Token
  class << self
    def create(user:, api_key_id:)
      payload = {
        user_id: user.id,
        api_key_id: api_key_id
      }

      super(payload)
    end
  end
end
