require "rails_helper"

RSpec.describe "industries/index" do
  it "displays industry names" do
    create(:industry, name: "Health", prefix: "39")
    create(:industry, name: "Business", prefix: "41")

    visit industries_path

    expect(page).to have_link "Health", href: occupation_standards_path(q: "39-")
    expect(page).to have_link "Business", href: occupation_standards_path(q: "41-")
  end
end
