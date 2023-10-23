require "rails_helper"

describe Rack::Attack do
  include Rack::Test::Methods

  # https://makandracards.com/makandra/46189-how-to-rails-cache-for-individual-rspec-tests
  # memory store is per process and therefore no conflicts in parallel tests
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:cache) { Rails.cache }

  before do
    Rack::Attack.enabled = true
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  after do
    Rack::Attack.enabled = false
  end

  def app
    Rails.application
  end

  describe "localhost is not throttled" do
    it "does not change the request status to 429" do
      6.times do |i|
        post "http://admin.example.com/users/sign_in", {}, {"REMOTE_ADDR" => "127.0.0.1"}

        expect(last_response.status).to eq(422)
      end
    end
  end

  describe "throttle excessive requests for email login" do
    it "changes the request status to 429 when higher than limit" do
      user = create(:user, email: "foo@example.com")

      5.times do |i|
        post "http://admin.example.com/users/sign_in", {user: {email: user.email, password: "badpassword"}}, {"REMOTE_ADDR" => "100.2.3.#{i}"}

        expect(last_response.status).to eq(422)
      end

      post "http://admin.example.com/users/sign_in", {user: {email: user.email, password: "badpassword"}}, {"REMOTE_ADDR" => "100.2.3.11"}

      expect(last_response.status).to eq(429)
      expect(last_response.body).to include("Retry later")
    end
  end

  describe "Allow2ban excessive requests by IP address" do
    context "login" do
      it "changes the request status to forbidden when higher than limit" do
        15.times do |i|
          email = "user#{i}@example.com"
          post "http://admin.example.com/users/sign_in", {user: {email: email, password: "password"}}, {"REMOTE_ADDR" => "1.221.3.4"}

          expect(last_response.status).to eq(422)
        end
        post "http://admin.example.com/users/sign_in", {user: {email: "user@example.com", password: "password"}}, {"REMOTE_ADDR" => "1.221.3.4"}

        expect(last_response.status).to eq(403)
        expect(last_response.body).to include("Forbidden")

        travel_to(61.minutes.from_now) do
          post "http://admin.example.com/users/sign_in", {}, {"REMOTE_ADDR" => "1.221.3.4"}

          expect(last_response.status).to eq(422)
        end
      end
    end

    context "reset password" do
      it "changes the request status to forbidden when higher than limit" do
        15.times do |i|
          email = "user#{i}@example.com"
          post "http://admin.example.com/users/password", {user: {email: email}}, {"REMOTE_ADDR" => "1.118.3.4"}

          expect(last_response.status).to eq(303)
        end
        post "http://admin.example.com/users/password", {user: {email: "user@example.com"}}, {"REMOTE_ADDR" => "1.118.3.4"}

        expect(last_response.status).to eq(403)
        expect(last_response.body).to include("Forbidden")

        travel_to(61.minutes.from_now) do
          post "http://admin.example.com/users/password", {user: {email: "u@example.com"}}, {"REMOTE_ADDR" => "1.118.3.4"}

          expect(last_response.status).to eq(303)
        end
      end
    end
  end

  describe "fail2ban" do
    it "changes the request status to 403" do
      ["/phpMyAdmin/", "/sql/phpmy-admin", "/etc/services"].each do |path|
        head path, {}, {"REMOTE_ADDR" => "1.2.3.4"}

        expect(last_response.status).to eq(403)
      end
    end
  end

  describe "blocklist" do
    context "bad ips" do
      # IP_BLOCKLIST environment variable set in config/environments/test.rb
      it "blocks requests" do
        ["4.5.6.7", "9.8.7.6", "100.101.102.103"].each do |remote_ip|
          post "/admin/login", {}, {"REMOTE_ADDR" => remote_ip}

          expect(last_response.status).to eq(403)
        end
      end
    end
  end
end
