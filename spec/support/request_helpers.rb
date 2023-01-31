module RequestHelpers
  def response_json
    @_response_json ||= if response
      JSON.parse(response.body)
    else
      fail "expected to find response, found nil"
    end
  end

  def json_response
    @_json_response ||= if response
      JSON.parse(response.body, symbolize_names: true)
    else
      fail "expected to find response, found nil"
    end
  end
end

RSpec.configure { |config| config.include RequestHelpers }
