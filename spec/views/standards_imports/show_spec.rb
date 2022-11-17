require "rails_helper"

RSpec.describe "standards_imports/show.html.erb", type: :view do
  it "has heading text" do
    assign(:standards_import, build(:standards_import))

    render

    expect(rendered).to have_text "Thank you for submitting your apprenticeship standards!"
  end

  it "displays standards import field values" do
    si = build(:standards_import,
      name: "Mickey Mouse",
      email: "mickey@example.com",
      organization: "Disney",
      notes: "a" * 300)
    assign(:standards_import, si)

    render

    expect(rendered).to have_text "Mickey Mouse"
    expect(rendered).to have_text "mickey@example.com"
    expect(rendered).to have_text "Disney"
    expect(rendered).to have_text "a" * 300
  end

  it "displays link to return to new upload page" do
    assign(:standards_import, build(:standards_import))

    render

    expect(rendered).to have_link "Upload more standards", href: new_standards_import_path
  end
end
