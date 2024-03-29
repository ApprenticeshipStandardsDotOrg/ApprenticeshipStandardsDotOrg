require "rails_helper"

RSpec.describe "Pages", type: :request do
  describe "GET /home" do
    it "returns http success" do
      allow(State).to receive(:find_by).and_return(build_stubbed(:state))

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

  describe "GET /definitions" do
    it "returns http success" do
      get definitions_page_path

      expect(response).to be_successful
    end
  end

  describe "GET /terms" do
    it "returns http success" do
      get terms_page_path

      expect(response).to be_successful
    end
  end
end
