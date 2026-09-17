require "rails_helper"

RSpec.describe GenerateOccupationStandardExportJob, type: :job do
  describe "#perform" do
    it "generates and attaches a cached working copy" do
      occupation_standard = create(:occupation_standard)
      export = instance_double(
        OccupationStandardExport,
        call: "document contents",
        filename: "working-copy.docx"
      )
      allow(OccupationStandardExport).to receive(:new).with(occupation_standard).and_return(export)

      described_class.perform_now(occupation_standard)

      expect(occupation_standard.working_copy_document).to be_attached
      expect(occupation_standard.working_copy_document.filename.to_s).to eq "working-copy.docx"
      expect(occupation_standard.working_copy_document.download).to eq "document contents"
      expect(occupation_standard).to be_working_copy_current
    end

    it "does not regenerate a current working copy" do
      occupation_standard = create(:occupation_standard)
      export = instance_double(
        OccupationStandardExport,
        call: "document contents",
        filename: "working-copy.docx"
      )
      allow(OccupationStandardExport).to receive(:new).once.and_return(export)
      described_class.perform_now(occupation_standard)

      described_class.perform_now(occupation_standard)
    end
  end
end
