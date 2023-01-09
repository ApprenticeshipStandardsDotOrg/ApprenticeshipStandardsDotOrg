require "rails_helper"

RSpec.describe RegistrationAgency, type: :model do
  it "has a valid factory" do
    ra = build(:registration_agency)
    
    expect(ra).to be_valid
  end
end
