require "oauth2"

module RAPIDS
  class API
    BASE_URL = "https://#{ENV["RAPIDS_SERVER_DOMAIN"]}".freeze
    TOKEN_URL = "#{BASE_URL}/suite/authorization/oauth/token".freeze
    BASE_PATH = "/suite/webapi/rapids/data-sharing/sponsor"

    def self.call
      new
    end

    def initialize
      @client = OAuth2::Client.new(
        ENV["RAPIDS_CLIENT_ID"],
        ENV["RAPIDS_CLIENT_SECRET"],
        site: BASE_URL,
        token_url: TOKEN_URL
      )

      get_token!
    end

    def work_processes(params = {})
      get("/wps", params)
    end

    private

    # Params supported by API:
    # batchSize: The maximum number of items to return in the response. If set to -1, all items will be returned.
    # startIndex: Index of the array in which to start returning values for the subset. Valid values include those greater than zero

    def get(path, params = {})
      @access.get("#{BASE_URL}#{BASE_PATH}#{path}", params: params)
    end

    def get_token!
      @access = @client.client_credentials.get_token
    end
  end
end
