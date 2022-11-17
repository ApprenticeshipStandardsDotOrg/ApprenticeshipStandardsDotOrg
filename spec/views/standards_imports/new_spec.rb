require "rails_helper"

RSpec.describe "standards_imports/new.html.erb", type: :view do
  it "has heading text" do
    render

    expect(rendered).to have_text "Upload Apprenticeship Standards"
  end
end
