class BackfillAIConversionSourceOnOccupationStandards < ActiveRecord::Migration[8.1]
  RAPIDS_API_SOURCE = 1
  ONET_API_SOURCE = 2
  AI_CONVERSION_SOURCE = 3

  def up
    execute <<~SQL.squish
      UPDATE occupation_standards
      SET source = #{AI_CONVERSION_SOURCE}
      WHERE id IN (
        SELECT occupation_standard_id
        FROM open_ai_imports
        WHERE occupation_standard_id IS NOT NULL
      )
    SQL

    execute <<~SQL.squish
      WITH RECURSIVE import_roots(import_id, parent_type, parent_id) AS (
        SELECT id, parent_type, parent_id
        FROM imports

        UNION ALL

        SELECT import_roots.import_id, parent_imports.parent_type, parent_imports.parent_id
        FROM import_roots
        INNER JOIN imports parent_imports
          ON import_roots.parent_type = 'Import'
          AND parent_imports.id = import_roots.parent_id
      )
      UPDATE occupation_standards
      SET source = #{RAPIDS_API_SOURCE}
      WHERE source IS NULL
        AND id IN (
          SELECT data_imports.occupation_standard_id
          FROM data_imports
          INNER JOIN import_roots
            ON import_roots.import_id = data_imports.import_id
          INNER JOIN standards_imports
            ON import_roots.parent_type = 'StandardsImport'
            AND standards_imports.id = import_roots.parent_id
          WHERE data_imports.occupation_standard_id IS NOT NULL
            AND (
              standards_imports.source_url = 'RAPIDSAPI'
              OR standards_imports.organization = 'RAPIDSAPI'
            )
        )
    SQL

    execute <<~SQL.squish
      WITH RECURSIVE import_roots(import_id, parent_type, parent_id) AS (
        SELECT id, parent_type, parent_id
        FROM imports

        UNION ALL

        SELECT import_roots.import_id, parent_imports.parent_type, parent_imports.parent_id
        FROM import_roots
        INNER JOIN imports parent_imports
          ON import_roots.parent_type = 'Import'
          AND parent_imports.id = import_roots.parent_id
      )
      UPDATE occupation_standards
      SET source = #{ONET_API_SOURCE}
      WHERE source IS NULL
        AND id IN (
          SELECT data_imports.occupation_standard_id
          FROM data_imports
          INNER JOIN import_roots
            ON import_roots.import_id = data_imports.import_id
          INNER JOIN standards_imports
            ON import_roots.parent_type = 'StandardsImport'
            AND standards_imports.id = import_roots.parent_id
          WHERE data_imports.occupation_standard_id IS NOT NULL
            AND (
              standards_imports.source_url IN ('ONETAPI', 'O*NETAPI', 'O*NET')
              OR standards_imports.organization IN ('ONETAPI', 'O*NETAPI', 'O*NET')
            )
        )
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
