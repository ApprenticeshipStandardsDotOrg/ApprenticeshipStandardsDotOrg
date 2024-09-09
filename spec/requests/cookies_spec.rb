require "rails_helper"

RSpec.describe "Cookies", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/cookies/create"
      expect(response).to have_http_status(:redirect)
    end
  end
end
