class DetectDisallowedWordsInTextRepresentationQuery
  def self.run(text_representation_id)
    result = TextRepresentation.connection.exec_query(
      TextRepresentation.sanitize_sql([
        "
          SELECT array_agg(rm[1]) AS WORDS
            FROM (
              SELECT ts_headline(
                content,
                to_tsquery(array_to_string(array_agg(word_replacements.word), ' | '))
              )
              FROM text_representations
              CROSS JOIN word_replacements
              WHERE text_representations.id = :text_representation_id
              GROUP BY content
            ) AS t(s)
            CROSS JOIN LATERAL regexp_matches(s, '<b>(.*?)</b>', 'g') AS rm(matches);
        ",
        {
          text_representation_id: text_representation_id
        }
      ])
    )

    result.rows.flatten.first
  end
end
