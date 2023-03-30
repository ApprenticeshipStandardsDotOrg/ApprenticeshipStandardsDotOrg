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
      expect(jwt.key_identifier).to eq api_key.id
    end
  end

  describe "#destroy_api_key!" do
    it "deletes api_key" do
      api_key = create(:api_key)
      user = api_key.user

      expect {
        user.destroy_api_key!(api_key.id)
      }.to change(user.api_keys, :count).by(-1)
    end
  end
end
