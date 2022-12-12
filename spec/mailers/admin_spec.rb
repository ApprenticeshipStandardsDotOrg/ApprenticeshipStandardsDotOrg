require "rails_helper"

RSpec.describe AdminMailer, type: :mailer do
  describe "new_standards_import" do
    let(:mail) { AdminMailer.new_standards_import }

    it "renders the headers" do
      expect(mail.subject).to eq("New standards import")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
