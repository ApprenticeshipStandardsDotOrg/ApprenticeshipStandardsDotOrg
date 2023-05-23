require "rails_helper"

RSpec.describe AdminMailer, type: :mailer do
  describe "new_standards_import" do
    it "renders the header and body correctly" do
      si = build(:standards_import, name: "Mickey", email: "mickey@mouse.com", organization: "Disney")
      allow(si).to receive(:file_count).and_return(10)

      mail = AdminMailer.new_standards_import(si)

      expect(mail.subject).to eq("New standards import uploaded")
      expect(mail.to).to eq(["patrick@workhands.us"])
      expect(mail.from).to eq(["no-reply@apprenticeshipstandards.org"])

      mail.body.parts.each do |part|
        expect(part.body.encoded).to match si.name
        expect(part.body.encoded).to match si.email
        expect(part.body.encoded).to match si.organization
        expect(part.body.encoded).to match "10 files uploaded"
      end
    end
  end

  describe "new_contact_request" do
    it "renders the header and body correctly" do
      contact = create(:contact_request, name: "Mickey", email: "mickey@mouse.com", organization: "Disney", message: "Some message")

      mail = AdminMailer.new_contact_request(contact)

      expect(mail.subject).to eq("New ApprenticeshipStandards Contact Request")
      expect(mail.to).to eq(["patrick@workhands.us"])
      expect(mail.from).to eq(["no-reply@apprenticeshipstandards.org"])

      mail.body.parts.each do |part|
        expect(part.body.encoded).to match contact.name
        expect(part.body.encoded).to match contact.email
        expect(part.body.encoded).to match contact.organization
        expect(part.body.encoded).to match contact.message
        expect(part.body.encoded).to match admin_contact_request_path(contact)
      end
    end
  end
end
