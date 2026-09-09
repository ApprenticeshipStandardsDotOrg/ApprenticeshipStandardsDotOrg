require "rails_helper"

Rails.application.load_tasks unless Rake::Task.task_defined?("occupation_standards:export")

RSpec.describe "occupation_standards:export" do
  before do
    Rake::Task["occupation_standards:export"].reenable
  end

  it "writes the export to the provided path" do
    occupation_standard = create(:occupation_standard, onet_code: "29-1141.00")
    path = Rails.root.join("tmp", "occupation-standard-export-spec.csv")

    Rake::Task["occupation_standards:export"].invoke(path.to_s)

    report = CSV.read(path, headers: true)
    expect(report.length).to eq 1
    expect(report.first["name"]).to eq occupation_standard.title
  ensure
    FileUtils.rm_f(path)
  end
end
