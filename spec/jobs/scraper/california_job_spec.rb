require "rails_helper"

RSpec.describe Scraper::CaliforniaJob, type: :job do
  describe "#perform" do
    it "downloads pdf files to an standards import record" do
      expect {
        described_class.new.perform
      }.to change(StandardsImport, :count).by(1)

      standard_import = StandardsImport.last
      expect(standard_import.files.count).to be > 0
    end
  end
end
