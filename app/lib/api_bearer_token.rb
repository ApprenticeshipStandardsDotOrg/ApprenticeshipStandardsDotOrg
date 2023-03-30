class APIBearerToken < Token
  class << self
    def create(user:, key_identifier:)
      payload = {
        user_id: user.id,
        encrypted_password: user.encrypted_password,
        key_identifier: key_identifier
      }

      super(payload)
    end
  end
end
