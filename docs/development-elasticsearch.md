# Refresh development Elasticsearch after a database pull

`bin/pull_production_database` automatically runs `development:reindex` after
restoring PostgreSQL. Keep local Elasticsearch running before starting the pull.
The task rebuilds search to match the restored database; `pg_restore` itself does
not run Rails indexing callbacks. A raw restore performed another way still needs
the standalone task below.

## Before rebuilding

1. Before the database pull or standalone rebuild, start your local Elasticsearch service using the [README setup](../README.md#elasticsearch-setup).
   The example below assumes its usual `localhost:9200` endpoint:

   ```sh
   curl --fail --silent --show-error http://localhost:9200
   ```

2. Pause Rails/Sidekiq processes that might write records while the indexes are
   rebuilt; keep Elasticsearch running. Use your normal local PostgreSQL
   connection settings. If necessary, set `POSTGRES_USER` to your local database
   role before running Rails commands.

3. Confirm Rails' development Elasticsearch client points to your local service.
   See `config/initializers/elasticsearch.rb`; the cloud connection branch is
   used only in production. This procedure replaces the two development indexes
   and the development synonym set. The reindex task does not change PostgreSQL records.

## Rebuild synonyms and both indexes

The database-pull script runs this task automatically with `RAILS_ENV=development`,
the restored database name, and a local PostgreSQL role from `POSTGRES_USER`, then
`PGUSER`, then the current operating-system user. It runs Rails from the repository
root even if you launched the pull elsewhere.

To rebuild independently, run from the repository root using your normal local
PostgreSQL connection settings:

```sh
RAILS_ENV=development bundle exec rails development:reindex
```

If reindexing fails during a database pull, PostgreSQL remains restored. The pull
script exits unsuccessfully and prints the retry command with its local database
and role settings. Fix the reported issue and run that command; another database
pull is unnecessary. The task refuses to run outside development and checks that
both index names are the expected development names.

The synonym set must exist **before** creating `occupation_standards_development`:
its search analyzer references `dynamic_synonyms_development`. The task replaces
that set with all current database rules, rather than restoring only one rule.

`force: true` recreates each named index with the current model's mappings and
settings, removing stale documents from the previous database. `refresh: true`
makes the imported documents searchable before the count check. Both models are
needed: `Occupation` is the reference catalog, and `OccupationStandard` contains
the actual program standards.

The task uses all database synonym rules, or the application's initial-setup
UX/User experience rule when the synonym table is empty; it creates no database
records.

The command prints the database and index counts and exits unsuccessfully if a
bulk operation fails or the counts differ. Serialization or connection errors
also stop the command. Resolve any reported error and repeat the rebuild; do not
assume a partially imported index is complete.

## Verify and resume development

You can inspect the index counts separately:

```sh
curl --fail --silent --show-error 'http://localhost:9200/_cat/indices/occupations_development,occupation_standards_development?v'
```

Use the Rails count comparison above as the record-count check; `_cat/indices`
also displays Elasticsearch's internal document statistics. Resume Rails and
Sidekiq, then check a public search and a restored standard's page. Repeat the
rebuild after another production database pull.

## Troubleshooting

- **Connection refused:** start the local Elasticsearch service and confirm the
  client endpoint and local security settings match the README setup.
- **Missing synonym set/index creation failure:** run the full procedure in
  order. `OccupationStandard` requires the development synonym set first.
- **`document_missing_exception` / 404 while saving an existing standard:** a
  restored PostgreSQL record may not yet have an Elasticsearch document. Rebuild
  the indexes. A Rails `after_commit` indexing error occurs after the database
  commit, so inspect stored data before retrying a conversion or another update.
  Rebuilding search does not require another AI extraction or production pull.
- **Pending migrations or serialization errors:** make the development database
  compatible with your checked-out code, resolve the reported failure, and rerun
  `development:reindex`. The restore has already completed.
- **Old records still appear:** importing into an existing index does not remove
  documents absent from the new database. The force rebuild above removes those
  stale documents without deleting unrelated indexes.
- **Setup reports nothing to do:** restored `AfterParty::TaskRecord` rows can
  mark historical setup/deployment tasks complete. Use this explicit rebuild
  rather than assuming `bin/setup` or `after_party:run` recreated search.

This is a development search refresh. It does not refresh the production search
cluster, database reference catalogs, source PDFs, or AI conversion results.
