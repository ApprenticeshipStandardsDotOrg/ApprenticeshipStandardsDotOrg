require "rails_helper"

RSpec.describe "occupation_standards/show" do
  it "displays title" do
    data_import = create(:data_import)
    occupation_standard = data_import.occupation_standard

    visit occupation_standard_path(occupation_standard)

    expect(page).to have_content occupation_standard.title
  end
end
