class Token
  attr_reader :jwt_token

  class << self
    def create(payload)
      jwt_token = JWT.encode(payload, secret_key, algorithm)

      new(jwt_token)
    end

    def secret_key
      Rails.application.secret_key_base
    end

    def algorithm
      "HS256"
    end
  end

  def initialize(jwt_token)
    @jwt_token = jwt_token
  end

  def method_missing(attr)
    decode[attr.to_s]
  end

  def respond_to_missing?(method_name, include_private = false)
    decode.has_key?(method_name.to_s) || super
  end

  private

  def decode
    @_decoded ||= JWT.decode(jwt_token, secret_key, algorithm)[0]
  end

  def secret_key
    self.class.secret_key
  end

  def algorithm
    self.class.algorithm
  end
end
