require "rails_helper"

RSpec.describe Token do
  it "returns a JWT encoded payload which can be decoded" do
    payload = {
      user_id: 1,
      password_digest: "abc123$"
    }
    token = described_class.create(payload)

    expect(token.user_id).to eq 1
    expect(token.password_digest).to eq "abc123$"
    expect(token.foo).to be_nil
    expect(token.jwt_token.split(".").length).to eq 3
  end
end
