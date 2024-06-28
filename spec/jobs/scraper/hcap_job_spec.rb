require "rails_helper"

RSpec.describe Scraper::HcapJob, type: :job do
  describe "#perform" do
    context "when files have not been downloaded previously" do
      it "creates standards import record and corresponding import records" do
        Dotenv.modify("AIRTABLE_PERSONAL_ACCESS_TOKEN" => "abc123") do
          stub_responses
          expect {
            described_class.new.perform
          }.to change(StandardsImport, :count).by(3)
            .and change(Imports::Uncategorized, :count).by(3)
            .and change(Imports::Pdf, :count).by(3)

          standards_import1 = StandardsImport.first
          expect(standards_import1.name).to eq "https://a687e559-f74f-4c1e-b81d-83ee37e94af3.usrfiles.com/ugd/a687e5_f76fa7a5877742dd9cca8653d2fd6264.pdf"
          expect(standards_import1.organization).to eq "National Center for Healthcare Apprenticeships"
          expect(standards_import1.notes).to eq "From Scraper::HcapJob"
          expect(standards_import1.public_document).to be true
          expect(standards_import1.source_url).to be_nil
          metadata1 = standards_import1.metadata
          expect(metadata1["Location"]).to eq "California"
          expect(metadata1["Care Setting"]).to eq "Ambulatory"
          expect(metadata1["Approval Date"]).to eq "Signed in 2017"
          expect(metadata1["PDF Download Resource"]).to eq "https://a687e559-f74f-4c1e-b81d-83ee37e94af3.usrfiles.com/ugd/a687e5_f76fa7a5877742dd9cca8653d2fd6264.pdf"
          expect(metadata1["Sponsor"]).to eq "National Center for Healthcare Apprenticeships"
          expect(metadata1["Registration Level"]).to eq "Federal"
          expect(metadata1["Document"]).to eq " Emergency Medical Technician"
          expect(metadata1["Resource Type"]).to eq "Work Processes, Related Outline"
          expect(metadata1["Occupation"]).to eq "Emergency Medical Technician"
          expect(metadata1["Apprenticeship Type"]).to eq "Competency-based"
          uncat1 = standards_import1.imports.last
          expect(uncat1.metadata).to eq standards_import1.metadata

          standards_import2 = StandardsImport.second
          expect(standards_import2.name).to eq "https://a687e559-f74f-4c1e-b81d-83ee37e94af3.usrfiles.com/ugd/a687e5_534fc5bb0217460d8d49a49b25841762.pdf"
          expect(standards_import2.organization).to eq "AHIMA Foundation"
          expect(standards_import2.notes).to eq "From Scraper::HcapJob"
          expect(standards_import2.public_document).to be true
          expect(standards_import2.source_url).to be_nil
          metadata2 = standards_import2.metadata
          expect(metadata2["Location"]).to eq "No results"
          expect(metadata2["Care Setting"]).to eq "Acute, Ambulatory"
          expect(metadata2["Approval Date"]).to eq "Signed in 2018"
          expect(metadata2["PDF Download Resource"]).to eq "https://a687e559-f74f-4c1e-b81d-83ee37e94af3.usrfiles.com/ugd/a687e5_534fc5bb0217460d8d49a49b25841762.pdf"
          expect(metadata2["Sponsor"]).to eq "AHIMA Foundation"
          expect(metadata2["Registration Level"]).to eq "Federal"
          expect(metadata2["Document"]).to eq "Health Information Management Privacy and Security Officer"
          expect(metadata2["Resource Type"]).to eq "Work Processes, Related Outline"
          expect(metadata2["Occupation"]).to eq "Health Information Management Business Analyst"
          expect(metadata2["Apprenticeship Type"]).to eq "Competency-based"
          uncat2 = standards_import2.imports.last
          expect(uncat2.metadata).to eq standards_import2.metadata

          standards_import3 = StandardsImport.third
          expect(standards_import3.name).to eq "https://a687e559-f74f-4c1e-b81d-83ee37e94af3.usrfiles.com/ugd/a687e5_8034a3f4112d4956a11337333229a16e.pdf"
          expect(standards_import3.organization).to eq "Institute for Wellness Education"
          expect(standards_import3.notes).to eq "From Scraper::HcapJob"
          expect(standards_import3.public_document).to be true
          metadata3 = standards_import3.metadata
          expect(metadata3["Location"]).to eq "New Jersey"
          expect(metadata3["Care Setting"]).to eq "Ambulatory"
          expect(metadata3["Approval Date"]).to eq "Signed in 2013"
          expect(metadata3["Sponsor"]).to eq "Institute for Wellness Education"
          expect(metadata3["Registration Level"]).to eq "Federal"
          expect(metadata3["Document"]).to eq "Wellness Coach"
          expect(metadata3["Resource Type"]).to eq "Work Processes, Related Outline"
          expect(metadata3["Occupation"]).to eq "Wellness Coach"
          expect(metadata3["Apprenticeship Type"]).to eq "Hybrid"
          uncat3 = standards_import3.imports.last
          expect(uncat3.metadata).to eq standards_import3.metadata
        end
      end
    end

    context "when some files have been downloaded previously" do
      it "creates standards import records for new pdfs only" do
        Dotenv.modify("AIRTABLE_PERSONAL_ACCESS_TOKEN" => "abc123") do
          stub_responses
          old_standards_import = create(:standards_import, name: "https://a687e559-f74f-4c1e-b81d-83ee37e94af3.usrfiles.com/ugd/a687e5_f76fa7a5877742dd9cca8653d2fd6264.pdf", organization: "National Center for Healthcare Apprenticeships")
          perform_enqueued_jobs do
            expect {
              described_class.new.perform
            }.to change(StandardsImport, :count).by(2)
              .and change(Imports::Uncategorized, :count).by(2)
              .and change(Imports::Pdf, :count).by(2)
          end
        end
      end
    end
  end

  def stub_responses
    json_file1 = file_fixture("scraper/hcap1.json")
    json_file2 = file_fixture("scraper/hcap2.json")
    stub_request(:get, /api.airtable.com/)
      .with(headers: {Authorization: "Bearer abc123"})
      .to_return(
        {status: 200, body: json_file1.read, headers: {}},
        {status: 200, body: json_file2.read, headers: {}}
      )

    pdf_file = file_fixture("pixel1x1.pdf")
    stub_request(:get, /usrfiles.*\.pdf/)
      .to_return(status: 200, body: pdf_file.read, headers: {})
  end
end
