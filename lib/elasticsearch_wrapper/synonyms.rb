module ElasticsearchWrapper
  class Synonyms
    SYNONYM_SET_NAME = "dynamic_synonyms_#{Rails.env}"
    def self.client
      @@client ||= Elasticsearch::Client.new
    end

    def self.add(rule_id:, value:)
      response = client.synonyms.put_synonym_rule(
        set_id: SYNONYM_SET_NAME,
        rule_id: rule_id,
        body: {
          synonyms: value
        }
      ).body

      response["result"].in? ["updated", "created"]
    rescue Elastic::Transport::Transport::Errors::NotFound
      false
    end

    def self.remove(rule_id:)
      response = client.synonyms.delete_synonym_rule(
        set_id: SYNONYM_SET_NAME,
        rule_id: rule_id
      ).body

      response["result"] == "deleted"
    rescue Elastic::Transport::Transport::Errors::NotFound
      false
    end
  end
end
