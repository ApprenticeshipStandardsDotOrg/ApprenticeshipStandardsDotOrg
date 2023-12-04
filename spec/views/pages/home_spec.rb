require "rails_helper"

RSpec.describe "pages/home", type: :view do
  it "displays the correct page title when page_title is not present" do
    allow(State).to receive(:find_by).and_return(build_stubbed(:state))
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:controller_name).and_return("pages")
    allow_any_instance_of(ActionView::TestCase::TestController).to receive(:current_user).and_return(nil)
    assign :popular_onet_codes, []
    assign :popular_industries, []
    assign :popular_states, []
    assign :recently_added_occupation_standards, []

    render template: "pages/home", layout: "layouts/application"

    expect(rendered).to have_title "ApprenticeshipStandardsDotOrg"
  end
end
