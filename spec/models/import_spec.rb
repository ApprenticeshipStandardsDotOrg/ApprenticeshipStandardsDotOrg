require "rails_helper"

RSpec.describe Import, type: :model do
  describe "#converted_with_ai?" do
    it "returns true when is has an associated OpenAIResponse" do
      open_ai_import = create(:open_ai_import, :with_pdf_import)
      import = open_ai_import.import

      expect(import).to be_converted_with_ai
    end

    it "returns false when is does not have an associated OpenAIResponse" do
      import = create(:imports_pdf)

      expect(import).to_not be_converted_with_ai
    end
  end
end
