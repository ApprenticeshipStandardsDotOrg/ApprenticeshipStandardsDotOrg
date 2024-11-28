require "rails_helper"

RSpec.describe GuestMailer, type: :mailer, aggregate_failures: true do
  describe "#manual_upload_conversion_complete" do
    it "renders the headers and body correctly" do
      Dotenv.modify("PUBLIC_DOMAIN" => "public.example.com") do
        perform_enqueued_jobs do
          file1 = file_fixture("pixel1x1.pdf")
          file2 = file_fixture("pixel1x1.jpg")

          standards_import = create(:standards_import, files: [file1, file2], courtesy_notification: :pending, email: "foo@example.com", name: "Foo")
          uncat1 = create(:imports_uncategorized, parent: standards_import, file: file1)
          uncat2 = create(:imports_uncategorized, parent: standards_import, file: file2)
          pdf1 = create(:imports_pdf, file: file1, parent: uncat1)
          pdf2 = create(:imports_pdf, file: file2, parent: uncat2)

          occupation_standard1 = create(:occupation_standard, title: "Mechanic")
          occupation_standard2 = create(:occupation_standard, title: "Pipe Fitter")
          occupation_standard3 = create(:occupation_standard, title: "Tree Trimmer")

          allow(pdf1).to receive(:associated_occupation_standards).and_return([occupation_standard1, occupation_standard2])
          allow(pdf2).to receive(:associated_occupation_standards).and_return([occupation_standard3])

          mail = GuestMailer.manual_upload_conversion_complete(
            email: "foo@example.com",
            source_files: [pdf1, pdf2]
          )
          expect(mail.subject).to eq("Your standards are live in the Apprenticeship Standards Library")
          expect(mail.to).to eq(["foo@example.com"])
          expect(mail.from).to eq(["no-reply@apprenticeshipstandards.org"])
          expect(mail.bcc).to eq(["info@workhands.us"])

          mail.body.parts.each do |part|
            expect(part.body).to match "received and converted"
            expect(part.body).to match "view them live"
            expect(part.body).to match "apprenticeshipstandards.org"
            expect(part.body).to match "Mechanic"
            expect(part.body).to match "Pipe Fitter"
            expect(part.body).to match "Tree Trimmer"
            expect(part.body).to match "from pixel1x1.pdf"
            expect(part.body).to match "from pixel1x1.jpg"
            expect(part.body).to match occupation_standard_url(occupation_standard1, host: "public.example.com")
            expect(part.body).to match occupation_standard_url(occupation_standard2, host: "public.example.com")
            expect(part.body).to match occupation_standard_url(occupation_standard3, host: "public.example.com")
          end
        end
      end
    end
  end

  describe "#monthly_manual_upload_conversions" do
    it "renders the headers and body correctly" do
      Dotenv.modify("PUBLIC_DOMAIN" => "public.example.com") do
        perform_enqueued_jobs do
          file1 = file_fixture("pixel1x1.pdf")
          file2 = file_fixture("pixel1x1.jpg")
          date_range = Date.new(2024, 2, 12)..Date.new(2024, 3, 13)

          standards_import = create(:standards_import, files: [file1, file2], courtesy_notification: :pending, email: "foo@example.com", name: "Foo")
          uncat1 = create(:imports_uncategorized, parent: standards_import, file: file1)
          uncat2 = create(:imports_uncategorized, parent: standards_import, file: file2)
          pdf1 = create(:imports_pdf, file: file1, parent: uncat1)
          pdf2 = create(:imports_pdf, file: file2, parent: uncat2)

          occupation_standard1 = create(:occupation_standard, title: "Mechanic")
          occupation_standard2 = create(:occupation_standard, title: "Pipe Fitter")
          occupation_standard3 = create(:occupation_standard, title: "Tree Trimmer")

          allow(pdf1).to receive(:associated_occupation_standards).and_return([occupation_standard1, occupation_standard2])
          allow(pdf2).to receive(:associated_occupation_standards).and_return([occupation_standard3])

          mail = GuestMailer.manual_submissions_during_period(
            date_range:,
            email: "foo@example.com",
            source_files: [pdf1, pdf2]
          )
          expect(mail.subject)
            .to eq("Standards converted in the Apprenticeship Standards Library from Feb. 12, 2024, through Mar. 13, 2024.")
          expect(mail.to).to eq(["foo@example.com"])
          expect(mail.from).to eq(["no-reply@apprenticeshipstandards.org"])
          expect(mail.bcc).to eq(["info@workhands.us"])

          mail.body.parts.each do |part|
            expect(part.body).to match "Feb. 12, 2024,"
            expect(part.body).to match "Mar. 13, 2024"
            expect(part.body).to match "received and converted"
            expect(part.body).to match "view them live"
            expect(part.body).to match "apprenticeshipstandards.org"
            expect(part.body).to match "Mechanic"
            expect(part.body).to match "Pipe Fitter"
            expect(part.body).to match "Tree Trimmer"
            expect(part.body).to match "from pixel1x1.pdf"
            expect(part.body).to match "from pixel1x1.jpg"
            expect(part.body).to match occupation_standard_url(occupation_standard1, host: "public.example.com")
            expect(part.body).to match occupation_standard_url(occupation_standard2, host: "public.example.com")
            expect(part.body).to match occupation_standard_url(occupation_standard3, host: "public.example.com")
          end
        end
      end
    end
  end
end
