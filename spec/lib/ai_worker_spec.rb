require "spec_helper"
require "tmpdir"
require "open3"
require "json"

RSpec.describe "AI worker process" do
  def launch(concurrency)
    Dir.mktmpdir do |directory|
      bundle = File.join(directory, "bundle")
      File.write(bundle, <<~RUBY)
        #!#{RbConfig.ruby}
        require "json"
        puts JSON.generate(args: ARGV, pool: ENV.fetch("RAILS_MAX_THREADS"))
      RUBY
      File.chmod(0o755, bundle)
      Open3.capture3(
        {"PATH" => "#{directory}:#{ENV.fetch("PATH")}", "AI_CONVERSION_CONCURRENCY" => concurrency, "RAILS_MAX_THREADS" => "3"},
        RbConfig.ruby, File.expand_path("../../bin/ai-worker", __dir__)
      )
    end
  end

  it "starts ten AI threads with a matching database pool by default" do
    output, _, status = launch(nil)

    expect(status).to be_success
    expect(JSON.parse(output)).to eq("args" => %w[exec sidekiq -c 10 -q ai_conversion], "pool" => "10")
  end

  it "scales the threads and database pool together independently of the web setting" do
    output, _, status = launch("20")

    expect(status).to be_success
    expect(JSON.parse(output)).to eq("args" => %w[exec sidekiq -c 20 -q ai_conversion], "pool" => "20")
  end

  it "rejects nonpositive concurrency before starting Sidekiq" do
    _, error, status = launch("0")

    expect(status).not_to be_success
    expect(error).to include("AI_CONVERSION_CONCURRENCY must be positive")
  end
end
