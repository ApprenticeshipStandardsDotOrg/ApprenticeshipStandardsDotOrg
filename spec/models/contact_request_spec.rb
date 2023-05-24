require "rails_helper"

RSpec.describe ContactRequest, type: :model do
  it "has a valid factory" do
    contact_request = build(:contact_request)

    expect(contact_request).to be_valid
  end

  describe "#notify_admin" do
    it "calls new_contact_request mailer on create but not update" do
      contact = build(:contact_request)

      mailer = double("mailer", deliver_later: nil)
      expect(AdminMailer).to receive(:new_contact_request).and_return(mailer)
      expect(mailer).to receive(:deliver_later)

      contact.save!

      expect(AdminMailer).to_not receive(:new_contact_request)

      contact.update!(name: "Minnie Mouse")
    end
  end
end
