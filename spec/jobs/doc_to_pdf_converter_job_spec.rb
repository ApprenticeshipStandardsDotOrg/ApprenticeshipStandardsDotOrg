require "rails_helper"

RSpec.describe DocToPdfConverterJob, "#perform", type: :job do
  it "calls DocToPdfConverter service" do
    source_file = create(:source_file)

    expect(DocToPdfConverter).to receive(:convert).with(source_file)

    described_class.new.perform(source_file)
  end
end
