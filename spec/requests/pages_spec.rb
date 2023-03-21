require "rails_helper"

RSpec.describe "Pages", type: :request do
  describe "GET /home" do
    it "returns http success" do
      get home_page_path

      expect(response).to be_successful
    end
  end

  describe "GET /about" do
    it "returns http success" do
      get about_page_path

      expect(response).to be_successful
    end
  end
end
