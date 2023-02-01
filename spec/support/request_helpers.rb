module RequestHelpers
  def response_json
    @_response_json ||= if response
      JSON.parse(response.body, symbolize_names: true)
    else
      fail "expected to find response, found nil"
    end
  end
end

RSpec.configure { |config| config.include RequestHelpers }
