RSpec.shared_examples "an imported file" do
  describe "#process" do
    it "exists" do
      expect(subject).to respond_to(:process),
        "#{subject} must respond to #process"

      meth = subject.method(:process)
      param_types = meth.parameters.map { _1[0].to_s }

      expect(param_types).to all(be_start_with("key")),
        "#process parameters must all be keyword arguments"
    end
  end
end
