require 'rails_helper'

RSpec.describe "Admin::RedactFiles", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/admin/redact_files/new"
      expect(response).to have_http_status(:success)
    end
  end

end
