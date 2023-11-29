require "rails_helper"

RSpec.describe GuestMailer, type: :mailer do
  describe "manual_upload_conversion_complete" do
    it "renders the headers and body correctly" do
      stub_const "ENV", ENV.to_h.merge("PUBLIC_DOMAIN" => "public.example.com")
      file1 = file_fixture("pixel1x1.pdf")
      file2 = file_fixture("pixel1x1.jpg")

      create(:standards_import, files: [file1, file2], courtesy_notification: :pending, email: "foo@example.com", name: "Foo")
      source_file1 = SourceFile.first
      source_file2 = SourceFile.last

      occupation_standards = create_pair(:occupation_standard)
      occupation_standard = create(:occupation_standard)

      allow(source_file1).to receive(:associated_occupation_standards).and_return(occupation_standards)
      allow(source_file2).to receive(:associated_occupation_standards).and_return([occupation_standard])

      mail = GuestMailer.manual_upload_conversion_complete(
        email: "foo@example.com",
        source_files: [source_file1, source_file2]
      )
      expect(mail.subject).to eq("Standards conversion completion")
      expect(mail.to).to eq(["foo@example.com"])
      expect(mail.from).to eq(["no-reply@apprenticeshipstandards.org"])

      mail.body.parts.each do |part|
        expect(part.body).to match "The following standards have been added"
        expect(part.body).to match "apprenticeshipstandards.org"
        expect(part.body).to match "pixel1x1.pdf"
        expect(part.body).to match "pixel1x1.jpg"
        expect(part.body).to match occupation_standard_url(occupation_standard, host: "public.example.com")
        expect(part.body).to match occupation_standard_url(occupation_standards.first, host: "public.example.com")
        expect(part.body).to match occupation_standard_url(occupation_standards.last, host: "public.example.com")
      end
    end
  end
end
