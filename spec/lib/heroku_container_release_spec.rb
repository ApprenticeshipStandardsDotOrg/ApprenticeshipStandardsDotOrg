require "spec_helper"
require "webmock/rspec"
require_relative "../../lib/heroku_container_release"

RSpec.describe HerokuContainerRelease do
  let(:images) { %w[web worker release].to_h { |type| [type, "sha256:#{"a" * 64}"] } }
  let(:service) { described_class.new(app: "example", api_key: "test-token", images: images, poll_interval: 0) }
  let(:url) { "https://api.heroku.com/apps/example" }
  let(:previous) { {id: "previous", version: 1, status: "succeeded"} }
  let(:pending) { {id: "new", version: 2, status: "pending"} }

  before do
    stub_request(:get, "#{url}/releases").to_return(
      {body: [previous].to_json},
      {body: [pending, previous].to_json}
    )
    stub_request(:patch, "#{url}/formation").with(
      headers: {"Authorization" => "Bearer test-token", "Accept" => "application/vnd.heroku+json; version=3.docker-releases"},
      body: {updates: images.map { |type, image| {type: type, docker_image: image} }}.to_json
    ).to_return(body: "[]")
  end

  it "releases all three process images and waits for migrations to succeed" do
    stub_request(:get, "#{url}/releases/new").to_return(
      {body: pending.to_json},
      {body: pending.merge(status: "succeeded").to_json}
    )

    expect(service.call.fetch("status")).to eq "succeeded"
    expect(a_request(:patch, "#{url}/formation")).to have_been_made.once
    expect(a_request(:get, "#{url}/releases/new")).to have_been_made.twice
  end

  it "fails the deployment when the release phase fails" do
    stub_request(:get, "#{url}/releases/new").to_return(body: pending.merge(status: "failed").to_json)

    expect { service.call }.to raise_error(/release v2 failed/)
  end

  it "completes a retry when the requested images are already released" do
    stub_request(:get, "#{url}/releases").to_return(body: [previous].to_json)

    expect(service.call.fetch("version")).to eq 1
    expect(a_request(:get, "#{url}/releases")).to have_been_made.twice
  end

  it "still waits for an existing pending release phase on a retry" do
    stub_request(:get, "#{url}/releases").to_return(body: [pending].to_json)
    stub_request(:get, "#{url}/releases/new").to_return(body: pending.merge(status: "succeeded").to_json)

    expect(service.call.fetch("status")).to eq "succeeded"
    expect(a_request(:get, "#{url}/releases/new")).to have_been_made.once
  end

  it "does not report a failed existing release as a successful retry" do
    stub_request(:get, "#{url}/releases").to_return(body: [previous.merge(status: "failed")].to_json)

    expect { service.call }.to raise_error(/release v1 failed/)
  end

  it "does not deploy incomplete process images" do
    images.delete("release")

    expect { service.call }.to raise_error(ArgumentError)
    expect(a_request(:patch, "#{url}/formation")).not_to have_been_made
  end

  it "bounds the wait for a missing release" do
    allow(service).to receive(:monotonic_time).and_return(0, 3601)

    expect { service.call }.to raise_error(/Timed out/)
  end

  it "reports HTTP failures without exposing credentials or response bodies" do
    stub_request(:patch, "#{url}/formation").to_return(status: 403, body: "private information")

    expect { service.call }.to raise_error("Heroku PATCH formation failed (HTTP 403)")
  end
end
