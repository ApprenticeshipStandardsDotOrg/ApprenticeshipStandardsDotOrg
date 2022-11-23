class Subdomain
  class << self
    def matches?(request)
      request.subdomain == "admin"
    end
  end
end
