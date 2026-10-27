require "rails_helper"

Rails.application.load_tasks unless Rake::Task.task_defined?("development:reindex")

RSpec.describe "development:reindex" do
  let(:task) { Rake::Task["development:reindex"] }
  let(:synonyms_client) { double("synonyms API", put_synonym: {}) }
  let(:client) { double("Elasticsearch client", synonyms: synonyms_client) }

  before do
    # CI seeds a UX synonym before the suite; isolate each example's rules.
    Synonym.delete_all
    task.reenable
    allow(Elasticsearch::Model).to receive(:client).and_return(client)
  end

  def configure_development
    allow(Rails.env).to receive(:development?).and_return(true)
    allow(Occupation).to receive_messages(index_name: "occupations_development", import: [], count: 2)
    allow(OccupationStandard).to receive_messages(index_name: "occupation_standards_development", import: [], count: 3)
    allow(client).to receive(:count).with(index: "occupations_development").and_return(double(body: {"count" => 2}))
    allow(client).to receive(:count).with(index: "occupation_standards_development").and_return(double(body: {"count" => 3}))
  end

  it "refuses to rebuild outside development before calling Elasticsearch" do
    expect(synonyms_client).not_to receive(:put_synonym)

    expect { task.invoke }.to raise_error(SystemExit)
  end

  it "restores every synonym before force importing and verifying both indexes" do
    configure_development
    first = create(:synonym, word: "UX", synonyms: "User experience")
    second = create(:synonym, word: "IT", synonyms: "Information technology")
    rules = [first, second].sort_by(&:id).map { |synonym| {id: synonym.id.to_s, synonyms: synonym.to_elasticsearch_value} }
    expect(synonyms_client).to receive(:put_synonym).with(id: ElasticsearchWrapper::Synonyms::SYNONYM_SET_NAME, body: {synonyms_set: rules}).ordered
    expect(Occupation).to receive(:import).with(force: true, refresh: true, batch_size: 500, return: "errors").ordered.and_return([])
    expect(OccupationStandard).to receive(:import).with(force: true, refresh: true, batch_size: 500, return: "errors").ordered.and_return([])

    expect { task.invoke }.not_to change(Synonym, :count)
  end

  it "refuses unexpected index names before changing synonyms or indexes" do
    configure_development
    allow(Occupation).to receive(:index_name).and_return("occupations_production")
    expect(synonyms_client).not_to receive(:put_synonym)
    expect(Occupation).not_to receive(:import)

    expect { task.invoke }.to raise_error(SystemExit)
  end

  it "supports an empty synonym table without creating database rows" do
    configure_development
    expect(synonyms_client).to receive(:put_synonym).with(id: ElasticsearchWrapper::Synonyms::SYNONYM_SET_NAME,
      body: {synonyms_set: [{id: "development-default-ux", synonyms: "UX,User experience"}]})

    expect { task.invoke }.not_to change(Synonym, :count)
  end

  it "stops on bulk errors instead of reporting a successful rebuild" do
    configure_development
    allow(Occupation).to receive(:import).and_return([{"index" => {"error" => "invalid document"}}])
    expect(OccupationStandard).not_to receive(:import)

    expect { task.invoke }.to raise_error(SystemExit)
  end

  it "fails when the database and index counts differ" do
    configure_development
    allow(client).to receive(:count).with(index: "occupations_development").and_return(double(body: {"count" => 1}))
    expect(OccupationStandard).not_to receive(:import)

    expect { task.invoke }.to raise_error(SystemExit)
  end
end
