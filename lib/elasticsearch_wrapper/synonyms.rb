module ElasticsearchWrapper
  class Synonyms
    SYNONYM_SET_NAME = "dynamic_synonyms_#{Rails.env}"
    def self.client
      @@client ||= Elasticsearch::Model.client
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
    end

    def self.remove(rule_id:)
      response = client.synonyms.delete_synonym_rule(
        set_id: SYNONYM_SET_NAME,
        rule_id: rule_id
      ).body

      response["result"] == "deleted"
    end

    def self.create_set(value:, rule_id:)
      response = client.synonyms.put_synonym(
        body: {
          synonyms_set: [
            {
              id: rule_id,
              synonyms: value
            }
          ]
        },
        id: SYNONYM_SET_NAME
      ).body

      response["result"].in? ["updated", "created"]
    end
  end
end
