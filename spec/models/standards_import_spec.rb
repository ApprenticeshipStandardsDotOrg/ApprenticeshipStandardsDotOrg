require "rails_helper"

RSpec.describe StandardsImport, type: :model do
  it "has a valid factory" do
    si = build(:standards_import)

    expect(si).to be_valid
  end

  describe "#notify_admin" do
    it "calls new_standards_import mailer on create" do
      si = build(:standards_import)

      mailer = double("mailer", deliver_later: nil)
      expect(AdminMailer).to receive(:new_standards_import).and_return(mailer)
      expect(mailer).to receive(:deliver_later)

      si.save!
    end

    it "does not call mailer when updated" do
      si = create(:standards_import)

      expect(AdminMailer).to_not receive(:new_standards_import)

      si.update!(name: "Minnie Mouse")
    end
  end
end
