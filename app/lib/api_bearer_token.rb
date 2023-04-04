class APIBearerToken < Token
  class << self
    def create(user:, api_key_id:)
      payload = {
        user_id: user.id,
        encrypted_password: user.encrypted_password,
        api_key_id: api_key_id
      }

      super(payload)
    end
  end
end
