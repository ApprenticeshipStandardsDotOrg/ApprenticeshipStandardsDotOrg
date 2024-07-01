require "rails_helper"

RSpec.describe AdminMailer, type: :mailer do
  describe "#new_standards_import" do
    it "renders the header and body correctly" do
      si = build(:standards_import, name: "Mickey", email: "mickey@mouse.com", organization: "Disney")
      uncat_imports = build_list(:imports_uncategorized, 10)
      allow(si).to receive(:imports).and_return(uncat_imports)

      mail = described_class.new_standards_import(si)

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

      mail = described_class.new_contact_request(contact)

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
        pdf = create(:imports_pdf)
        data_import = create(:data_import, created_at: Time.zone.local(2023, 6, 14), import: pdf)
        occupation_standard = data_import.occupation_standard
        occupation_standard.update!(ojt_hours_min: 100, ojt_hours_max: 200, rsi_hours_min: 500, rsi_hours_max: 600, title: "Mechanic")
        allow_any_instance_of(OccupationStandard).to receive(:competencies_count).and_return(123)

        mail = described_class.daily_uploads_report

        expect(mail.subject).to eq("Daily imported standards report 2023-06-14")
        expect(mail.to).to eq(["info@workhands.us"])
        expect(mail.from).to eq(["no-reply@apprenticeshipstandards.org"])

        mail.body.parts.each do |part|
          expect(part.body.encoded).to match "Mechanic"
          expect(part.body.encoded).to match "Public"
          expect(part.body.encoded).to match "Admin"
          expect(part.body.encoded).to match "Data Import"
          expect(part.body.encoded).to match "Source File"
          expect(part.body.encoded).to match occupation_standard_url(occupation_standard)
          expect(part.body.encoded).to match admin_occupation_standard_url(occupation_standard)
          expect(part.body.encoded).to match admin_data_import_url(data_import)
          expect(part.body.encoded).to match admin_import_url(pdf)
          expect(part.body.encoded).to match "Competencies count: 123"
          expect(part.body.encoded).to match "OJT hours min: 100"
          expect(part.body.encoded).to match "OJT hours max: 200"
          expect(part.body.encoded).to match "RSI hours min: 500"
          expect(part.body.encoded).to match "RSI hours max: 600"
        end
      end
    end

    it "does not send mail if no imports" do
      expect {
        described_class.daily_uploads_report.deliver_now
      }.not_to change(ActionMailer::Base.deliveries, :count)
    end
  end

  describe "#daily_redacted_files_report" do
    it "renders the header and body correctly" do
      travel_to(Time.zone.local(2023, 6, 15)) do
        import = create(:imports_pdf, redacted_at: Time.zone.local(2023, 6, 14))

        mail = described_class.daily_redacted_files_report

        expect(mail.subject).to eq("Daily redacted files report 2023-06-14")
        expect(mail.to).to eq(["info@workhands.us"])
        expect(mail.from).to eq(["no-reply@apprenticeshipstandards.org"])

        mail.body.parts.each do |part|
          expect(part.body.encoded).to match import.filename
          expect(part.body.encoded).to match admin_import_url(import)
        end
      end
    end

    it "with import feature flag: does not send mail if no imports" do
      expect {
        described_class.daily_redacted_files_report.deliver_now
      }.not_to change(ActionMailer::Base.deliveries, :count)
    end
  end
end
