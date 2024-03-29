require "rails_helper"
require "elasticsearch_wrapper/synonyms"

RSpec.describe ElasticsearchWrapper::Synonyms do
  describe ".client" do
    it "returns an Elasticsearch::Client instance" do
      expect(described_class.client).to be_a Elasticsearch::Client
    end
  end

  describe ".add" do
    it "returns true when creating a new record" do
      value = "Software Engineer, Developer"
      id = "1"

      allow_any_instance_of(
        Elasticsearch::API::Synonyms::SynonymsClient
      ).to receive(
        :put_synonym_rule
      ).with(
        set_id: ElasticsearchWrapper::Synonyms::SYNONYM_SET_NAME,
        rule_id: id,
        body: {
          synonyms: value
        }
      ).and_return(mock_elasticsearch_response_with("created"))

      expect(
        described_class.add(
          rule_id: id,
          value: value
        )
      ).to be true
    end

    it "returns true when updating a record" do
      value = "Software Engineer, Developer"
      id = "1"

      allow_any_instance_of(
        Elasticsearch::API::Synonyms::SynonymsClient
      ).to receive(
        :put_synonym_rule
      ).with(
        set_id: ElasticsearchWrapper::Synonyms::SYNONYM_SET_NAME,
        rule_id: id,
        body: {
          synonyms: value
        }
      ).and_return(mock_elasticsearch_response_with("updated"))

      expect(
        described_class.add(
          rule_id: id,
          value: value
        )
      ).to be true
    end

    it "throws an error when synonym set name does not exist" do
      value = "Software Engineer, Developer"
      id = "1"

      stub_const("ElasticsearchWrapper::Synonyms::SYNONYM_SET_NAME", "nonexistent")
      allow_any_instance_of(
        Elasticsearch::API::Synonyms::SynonymsClient
      ).to receive(
        :put_synonym_rule
      ).with(
        set_id: ElasticsearchWrapper::Synonyms::SYNONYM_SET_NAME,
        rule_id: id,
        body: {
          synonyms: value
        }
      ).and_raise(Elastic::Transport::Transport::Errors::NotFound)

      expect {
        described_class.add(
          rule_id: id,
          value: value
        )
      }.to raise_error Elastic::Transport::Transport::Errors::NotFound
    end
  end

  describe ".remove" do
    it "returns true when removing an existing entry record" do
      id = "1"

      allow_any_instance_of(
        Elasticsearch::API::Synonyms::SynonymsClient
      ).to receive(
        :delete_synonym_rule
      ).with(
        set_id: ElasticsearchWrapper::Synonyms::SYNONYM_SET_NAME,
        rule_id: id
      ).and_return(mock_elasticsearch_response_with("deleted"))

      expect(
        described_class.remove(
          rule_id: id
        )
      ).to be true
    end

    it "throws an error when trying to remove an innexisting record" do
      id = "1"

      allow_any_instance_of(
        Elasticsearch::API::Synonyms::SynonymsClient
      ).to receive(
        :delete_synonym_rule
      ).with(
        set_id: ElasticsearchWrapper::Synonyms::SYNONYM_SET_NAME,
        rule_id: id
      ).and_raise(Elastic::Transport::Transport::Errors::NotFound)

      expect {
        described_class.remove(
          rule_id: id
        )
      }.to raise_error Elastic::Transport::Transport::Errors::NotFound
    end
  end

  describe ".create_set" do
    it "returns true when creating a set" do
      id = "1"
      value = "Software Engineer, Developer"

      allow_any_instance_of(
        Elasticsearch::API::Synonyms::SynonymsClient
      ).to receive(
        :put_synonym
      ).with(
        body: {
          synonyms_set: [
            {
              id: id,
              synonyms: value
            }
          ]
        },
        id: ElasticsearchWrapper::Synonyms::SYNONYM_SET_NAME
      ).and_return(mock_elasticsearch_response_with("created"))

      expect(
        described_class.create_set(
          rule_id: id,
          value: value
        )
      ).to be true
    end

    it "returns true when updating a set" do
      id = "1"
      value = "Software Engineer, Developer"

      allow_any_instance_of(
        Elasticsearch::API::Synonyms::SynonymsClient
      ).to receive(
        :put_synonym
      ).with(
        body: {
          synonyms_set: [
            {
              id: id,
              synonyms: value
            }
          ]
        },
        id: ElasticsearchWrapper::Synonyms::SYNONYM_SET_NAME
      ).and_return(mock_elasticsearch_response_with("updated"))

      expect(
        described_class.create_set(
          rule_id: id,
          value: value
        )
      ).to be true
    end

    it "throws error if set cannot be create" do
      id = "1"
      value = "Software Engineer, Developer"

      allow_any_instance_of(
        Elasticsearch::API::Synonyms::SynonymsClient
      ).to receive(
        :put_synonym
      ).with(
        body: {
          synonyms_set: [
            {
              id: id,
              synonyms: value
            }
          ]
        },
        id: ElasticsearchWrapper::Synonyms::SYNONYM_SET_NAME
      ).and_raise(Elastic::Transport::Transport::Errors::NotFound)

      expect {
        described_class.create_set(
          rule_id: id,
          value: value
        )
      }.to raise_error Elastic::Transport::Transport::Errors::NotFound
    end
  end

  def mock_elasticsearch_response_with(response)
    OpenStruct.new(body: {
      "result" => response
    })
  end
end
