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
      expect(jwt.encrypted_password).to be_nil
      expect(jwt.api_key_id).to eq api_key.id
    end
  end

  describe "#password_required?" do
    it "returns false when creating a user" do
      user = build(:user)

      expect(user.password_required?).to be false
    end

    it "returns true when record already exists" do
      user = create(:user)

      expect(user.password_required?).to be true
    end

    it "returns true when updating a user and it does have a password" do
      user = create(:user, password: "passworddefined")

      expect(user.password_required?).to be true
    end

    it "returns true when updating a user and it does have a password confirmation" do
      user = create(:user, password_confirmation: "passworddefined")

      expect(user.password_required?).to be true
    end

    it "returns false when updating a user that does not have a password or password confirmation" do
      user = create(:user, password: nil, password_confirmation: nil)

      expect(user.password_required?).to be false
    end
  end
end
