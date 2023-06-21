class SearchTermExtractor
  def self.call(params)
    return params if params[:q].blank?

    (
      EXTRACT_STATE <<
      EXTRACT_OJT_TYPE <<
      EXTRACT_NATIONAL_STANDARD_TYPE
    ).call(params)
  end

  BASE_EXTRACTION = ->(params, value, &block) do
    expression = "#{value}:(\\S*)"
    updated_params = params.dup
    regex = Regexp.new expression

    if regex =~ params[:q]
      updated_params[:q] = params[:q].sub(regex, "").strip
      updated_params[value] = block.call($1)
      updated_params
    else
      params
    end
  end

  EXTRACT_STATE = ->(params) do
    BASE_EXTRACTION.call(params, :state) { |value| value }
  end

  EXTRACT_OJT_TYPE = ->(params) do
    BASE_EXTRACTION.call(params, :ojt_type) { |value|
      values = {}
      values[value.to_sym] = 1
      values
    }
  end

  EXTRACT_NATIONAL_STANDARD_TYPE = ->(params) do
    BASE_EXTRACTION.call(params, :national_standard_type) { |value|
      values = {}
      values[value.to_sym] = 1
      values
    }
  end
end
