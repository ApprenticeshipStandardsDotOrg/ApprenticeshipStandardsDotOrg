module ElasticsearchWrapper
  class Synonyms
    SYNONYM_SET_NAME = "dynamic_synonyms"
    def self.client
      @@client ||= Elasticsearch::Client.new
    end

    def self.add(rule_id:, value:)
      client.synonyms.put_synonym_rule(
        set_id: SYNONYM_SET_NAME,
        rule_id: rule_id,
        body: {
          synonyms: value
        }
      ).body
    end

    def self.remove(rule_id:)
      client.synonyms.delete_synonym_rule(
        set_id: SYNONYM_SET_NAME,
        rule_id: rule_id
      ).body
    end

    def self.list
      client.synonyms.get_synonym(
        id: SYNONYM_SET_NAME
      ).body
    end
  end
end
