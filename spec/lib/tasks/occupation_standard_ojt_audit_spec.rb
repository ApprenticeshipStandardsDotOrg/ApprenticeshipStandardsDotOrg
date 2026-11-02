require "rails_helper"
require "tempfile"

Rails.application.load_tasks unless Rake::Task.task_defined?("occupation_standards:ojt_audit")

RSpec.describe "occupation_standards:ojt_audit" do
  let(:task) { Rake::Task["occupation_standards:ojt_audit"] }

  before { task.reenable }

  it "uses the fixed CSV IDs rather than current sample membership" do
    baseline = create(:occupation_standard, sample_set: false)
    create(:occupation_standard, sample_set: true)
    report = instance_double(OccupationStandardOJTAuditReport, to_csv: "audit output\n")
    expect(OccupationStandardOJTAuditReport).to receive(:new) do |scope, filters:|
      expect(scope.pluck(:id)).to eq [baseline.id]
      report
    end
    expect(ChatGptGenerateText).not_to receive(:new)

    Tempfile.create(["ojt-benchmark", ".csv"]) do |input|
      input.write("id\nhttps://admin.apprenticeshipstandards.org/admin/occupation_standards/#{baseline.id}\n")
      input.flush
      Tempfile.create(["ojt-audit", ".csv"]) do |output|
        task.invoke(input.path, output.path)

        expect(File.read(output.path)).to eq "audit output\n"
      end
    end
  end

  it "rejects overwriting the fixed benchmark" do
    Tempfile.create(["ojt-benchmark", ".csv"]) do |input|
      input.write("id\n")
      input.flush

      expect { task.invoke(input.path, input.path) }.to raise_error(ArgumentError, /overwrite/)
      expect(File.read(input.path)).to eq "id\n"
    end
  end

  it "reports missing benchmark records before attempting source downloads" do
    Tempfile.create(["ojt-benchmark", ".csv"]) do |input|
      input.write("id\n00000000-0000-0000-0000-000000000000\n")
      input.flush

      expect { task.invoke(input.path, "tmp/unused-ojt-output.csv") }.to raise_error(ArgumentError, /missing/)
    end
  end
end
