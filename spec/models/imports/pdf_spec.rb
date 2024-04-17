require "rails_helper"

RSpec.describe Imports::Pdf, type: :model do
  it_behaves_like "an imported file"

  it "updates the processing data" do
    pdf = create(:imports_pdf)

    pdf.process
    pdf.reload

    expect(pdf.processed_at).to be_present
    expect(pdf.processing_errors).to be_blank
    expect(pdf.status).to eq("completed")
  end
end
