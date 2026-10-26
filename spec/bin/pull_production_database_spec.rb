require "spec_helper"
require "fileutils"
require "etc"
require "json"
require "open3"
require "rbconfig"
require "tmpdir"

RSpec.describe "bin/pull_production_database" do
  around do |example|
    Dir.mktmpdir("database-pull-spec") do |directory|
      @root = directory
      FileUtils.mkdir_p(File.join(directory, "bin"))
      @script = File.join(directory, "bin/pull_production_database")
      FileUtils.cp(File.expand_path("../../bin/pull_production_database", __dir__), @script)
      @log = File.join(directory, "calls.jsonl")
      shims = File.join(directory, "shims")
      FileUtils.mkdir_p(shims)
      fake = File.join(shims, "fake")
      File.write(fake, <<~RUBY)
        #!#{RbConfig.ruby}
        require "json"
        command = File.basename($PROGRAM_NAME)
        File.open(ENV.fetch("PULL_TEST_LOG"), "a") do |file|
          file.puts({command: command, args: ARGV, cwd: Dir.pwd,
            env: ENV.slice("RAILS_ENV", "POSTGRES_DB", "POSTGRES_USER")}.to_json)
        end
        exit(ENV["PULL_TEST_FAIL"] == command ? 1 : 0)
      RUBY
      FileUtils.chmod(0o755, fake)
      %w[heroku psql pg_restore bundle].each { |name| File.symlink(fake, File.join(shims, name)) }
      @env = {"PATH" => "#{shims}#{File::PATH_SEPARATOR}#{ENV.fetch("PATH")}",
              "PULL_TEST_LOG" => @log, "POSTGRES_USER" => "local_restore_role", "PULL_TEST_FAIL" => nil}
      example.run
    end
  end

  def run_pull(input: "apprenticeship_standards_development\n", fail_command: nil)
    Open3.capture3(@env.merge("PULL_TEST_FAIL" => fail_command), RbConfig.ruby, @script, stdin_data: input, chdir: @root)
  end

  def calls
    File.exist?(@log) ? File.readlines(@log).map { |line| JSON.parse(line) } : []
  end

  it "reindexes the restored development database after all restore commands finish" do
    output, _, status = run_pull

    expect(status).to be_success
    expect(calls.last).to include("command" => "bundle", "args" => ["exec", "rails", "development:reindex"], "cwd" => @root,
      "env" => {"RAILS_ENV" => "development", "POSTGRES_DB" => "apprenticeship_standards_development", "POSTGRES_USER" => "local_restore_role"})
    expect(calls[-2]["command"]).to eq "psql"
    expect(output).to include "development search rebuilt"
  end

  it "does not reindex after a failed database restore" do
    _, _, status = run_pull(fail_command: "pg_restore")

    expect(status).not_to be_success
    expect(calls.map { |call| call["command"] }).not_to include "bundle"
  end

  it "uses the libpq role when the Rails role is not configured" do
    @env["POSTGRES_USER"] = nil
    @env["PGUSER"] = "libpq_role"

    _, _, status = run_pull

    expect(status).to be_success
    expect(calls.last["env"]["POSTGRES_USER"]).to eq "libpq_role"
  end

  it "falls back to the operating-system role for local peer authentication" do
    @env["POSTGRES_USER"] = nil
    @env["PGUSER"] = nil

    _, _, status = run_pull

    expect(status).to be_success
    expect(calls.last["env"]["POSTGRES_USER"]).to eq Etc.getpwuid.name
  end

  it "reports that the database is restored when reindexing fails and provides a retry command" do
    _, error, status = run_pull(fail_command: "bundle")

    expect(status).not_to be_success
    expect(error).to include "database restore succeeded", "bundle exec rails development:reindex", "pull does not need to be repeated"
    expect(calls.last["command"]).to eq "bundle"
  end

  it "does not run external commands without confirmation" do
    _, _, status = run_pull(input: "no\n")

    expect(status).not_to be_success
    expect(calls).to be_empty
  end
end
