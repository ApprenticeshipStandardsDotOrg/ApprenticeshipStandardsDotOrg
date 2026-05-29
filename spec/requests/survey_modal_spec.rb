require "rails_helper"

RSpec.describe "Survey modal", type: :request do
  describe "GET /occupation_standards/:id" do
    it "shows the survey modal after an accepted-cookie visitor views a standard twice" do
      occupation_standard = create(:occupation_standard, :with_data_import)

      post cookies_path, params: {cookies: true}

      get occupation_standard_path(occupation_standard)
      expect(response.body).not_to include("Apprenticeship Standard Survey")

      get occupation_standard_path(occupation_standard)
      expect(response.body).to include("Apprenticeship Standard Survey")
    end

    it "does not show the survey modal when cookies are rejected" do
      occupation_standard = create(:occupation_standard, :with_data_import)

      post cookies_path, params: {cookies: false}

      get occupation_standard_path(occupation_standard)
      expect(response.body).not_to include("Apprenticeship Standard Survey")

      get occupation_standard_path(occupation_standard)
      expect(response.body).not_to include("Apprenticeship Standard Survey")
    end
  end

  describe "POST /surveys" do
    it "does not show the survey modal again after submission" do
      occupation_standard = create(:occupation_standard, :with_data_import)

      post cookies_path, params: {cookies: true}
      get occupation_standard_path(occupation_standard)
      get occupation_standard_path(occupation_standard)

      expect(response.body).to include("Apprenticeship Standard Survey")

      post surveys_path,
        params: {
          survey: {
            name: "Bob",
            email: "bob@apprenticeshipstandards.org",
            organization: "Apprenticeship Standards"
          }
        },
        headers: {"HTTP_REFERER" => occupation_standard_url(occupation_standard)}

      get occupation_standard_path(occupation_standard)
      expect(response.body).not_to include("Apprenticeship Standard Survey")
    end
  end

  describe "POST /surveys/dismiss" do
    it "does not show the survey modal again immediately after dismissal" do
      occupation_standard = create(:occupation_standard, :with_data_import)

      post cookies_path, params: {cookies: true}
      get occupation_standard_path(occupation_standard)
      get occupation_standard_path(occupation_standard)

      expect(response.body).to include("Apprenticeship Standard Survey")

      post dismiss_surveys_path,
        headers: {"HTTP_REFERER" => occupation_standard_url(occupation_standard)}

      get occupation_standard_path(occupation_standard)
      expect(response.body).not_to include("Apprenticeship Standard Survey")
    end
  end
end
