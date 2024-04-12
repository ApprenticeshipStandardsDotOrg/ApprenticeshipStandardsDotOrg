RSpec.shared_examples "an imported file" do
  describe "#process" do
    it "exists" do
      expect(subject).to respond_to(:process)
    end
  end
end
