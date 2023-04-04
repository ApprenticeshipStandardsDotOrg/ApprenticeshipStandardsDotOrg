require "rails_helper"

RSpec.describe User, type: :model do
  it "has a valid factory" do
    user = build(:user)

    expect(user).to be_valid
  end

  describe "#create_api_access_token!" do
    it "returns decodable jwt token" do
      user = create(:user)
      jwt = user.create_api_access_token!
      api_key = user.api_keys.last

      expect(jwt.user_id).to eq user.id
      expect(jwt.encrypted_password).to eq user.encrypted_password
      expect(jwt.api_key_id).to eq api_key.id
    end
  end
end
