require "spec_helper"
require "json"
require_relative "../../lib/rspec_shards"

RSpec.describe RspecShards do
  it "balances whole files using recorded runtimes" do
    files = %w[a b c d]
    runtimes = {"a" => 10, "b" => 6, "c" => 3, "d" => 1}

    expect(described_class.partition(files, count: 2, runtimes: runtimes)).to eq [%w[a], %w[b c d]]
  end

  it "includes new files exactly once and makes input ordering irrelevant" do
    files = %w[c a b]
    groups = described_class.partition(files, count: 2, runtimes: {"a" => 5})

    expect(groups.flatten.sort).to eq files.sort
    expect(described_class.partition(files.reverse, count: 2, runtimes: {"a" => 5})).to eq groups
  end

  it "rejects an invalid shard count" do
    expect { described_class.partition(["a"], count: 0) }.to raise_error(ArgumentError)
  end

  it "records runtimes against owning spec files rather than shared definitions" do
    runtimes = JSON.parse(File.read(File.expand_path("../../config/rspec_runtimes.json", __dir__)))

    expect(runtimes.keys).to all(match(%r{\Aspec/.*_spec\.rb\z}))
  end
end
