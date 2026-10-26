namespace :development do
  desc "Rebuild development Elasticsearch synonyms and both search indexes"
  task reindex: :environment do
    abort "development:reindex requires RAILS_ENV=development" unless Rails.env.development?

    models = [Occupation, OccupationStandard]
    expected_indexes = %w[occupations_development occupation_standards_development]
    abort "Unexpected development index names" unless models.map(&:index_name) == expected_indexes

    client = Elasticsearch::Model.client
    rules = Synonym.order(:id).map do |synonym|
      {id: synonym.id.to_s, synonyms: synonym.to_elasticsearch_value}
    end
    rules = [{id: "development-default-ux", synonyms: "UX,User experience"}] if rules.empty?
    client.synonyms.put_synonym(
      id: ElasticsearchWrapper::Synonyms::SYNONYM_SET_NAME,
      body: {synonyms_set: rules}
    )
    puts "Restored #{rules.length} development synonym rules"

    models.each do |model|
      errors = model.import(force: true, refresh: true, batch_size: 500, return: "errors")
      abort "#{model.name}: #{errors.length} bulk import errors: #{errors.first(3).inspect}" if errors.any?

      database_count = model.count
      indexed_count = client.count(index: model.index_name).body.fetch("count")
      puts "#{model.index_name}: database=#{database_count}, indexed=#{indexed_count}"
      abort "Count mismatch for #{model.name}" unless indexed_count == database_count
    end
  end
end
