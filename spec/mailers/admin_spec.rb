require "rails_helper"

RSpec.describe AdminMailer, type: :mailer do
  describe "#new_standards_import" do
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

  describe "#new_contact_request" do
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
        expect(part.body.encoded).to match admin_contact_request_url(contact)
      end
    end
  end

  describe "#daily_uploads_report" do
    it "renders the header and body correctly" do
      travel_to(Time.zone.local(2023, 6, 15)) do
        data_import = create(:data_import, created_at: Time.zone.local(2023, 6, 14))
        source_file = data_import.source_file
        occupation_standard = data_import.occupation_standard
        occupation_standard.update!(ojt_hours_min: 100, ojt_hours_max: 200, rsi_hours_min: 500, rsi_hours_max: 600)
        allow_any_instance_of(OccupationStandard).to receive(:competencies_count).and_return(123)

        mail = AdminMailer.daily_uploads_report

        expect(mail.subject).to eq("Daily imported standards report 2023-06-14")
        expect(mail.to).to eq(["info@workhands.us"])
        expect(mail.from).to eq(["no-reply@apprenticeshipstandards.org"])

        mail.body.parts.each do |part|
          expect(part.body.encoded).to match "Public occupation standard view"
          expect(part.body.encoded).to match occupation_standard_url(occupation_standard)
          expect(part.body.encoded).to match "Admin Data Import"
          expect(part.body.encoded).to match admin_data_import_url(data_import)
          expect(part.body.encoded).to match "Admin Source File"
          expect(part.body.encoded).to match admin_source_file_url(source_file)
          expect(part.body.encoded).to match "Competencies count: 123"
          expect(part.body.encoded).to match "OJT hours: 100-200"
          expect(part.body.encoded).to match "RSI hours: 500-600"
        end
      end
    end
  end
end
