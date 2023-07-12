require "rails_helper"

RSpec.describe "contact_requests" do
  it "allows users to send a message" do
    allow(State).to receive(:find_by).and_return(build_stubbed(:state))

    visit contact_page_path

    fill_in "Name", with: "Fernando"
    fill_in "Organization", with: "thoughtbot.inc"
    fill_in "Email", with: "fer@thoughtbot.com"
    fill_in "Message", with: "Sample message"

    click_button "Submit"

    expect(page).to have_alert("Thank you for contacting us! We've received your note and will reply to you soon!")
  end
end
