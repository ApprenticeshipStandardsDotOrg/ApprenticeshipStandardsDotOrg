class Subdomain
  class << self
    def matches?(request)
      request.subdomain&.match?(/admin/)
    end
  end
end
