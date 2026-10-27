# ApprenticeshipStandards.org agent guide

Use this file as durable repository context. Inspect the relevant code before acting: this is a map and a set of constraints, not a substitute for the current implementation.

## Product and domain

ApprenticeshipStandards.org publishes searchable occupational standards: the on-the-job learning (OJL/OJT), competencies, related technical instruction (RTI/RSI), wages, and registration context for registered apprenticeship programs.

- `OccupationStandard` is a particular standard used by a sponsor/program. It is the primary public record and has a stable UUID used in external links.
- `Occupation` is a reference occupation from the federal RAPIDS occupation list. A RAPIDS code identifies that reference occupation; many standards can relate to it.
- `Onet` is an O*NET-SOC reference record. O*NET codes can change across releases, represented by `OnetMapping`.
- OA means the US Department of Labor Office of Apprenticeship. SAA means a State Apprenticeship Agency. `RegistrationAgency` records the governing agency type and optional state.
- States are not uniformly OA or SAA. Use `RegistrationAgency.registration_agency_for_state`; do not infer agency type from general intuition. California can have either and has explicit handling.
- Standards may be time-based, competency-based, or hybrid. Time-based work processes carry hours; competency-based processes carry competencies; hybrid data may carry both.
- National standard types are program standard, guideline standard, and occupational framework. A blank type is meaningful and should not be silently classified.

Extraction logic and tests must work for both OA and SAA documents. Do not improve the current OA sample by introducing OA-specific assumptions that reduce generality.

## Core data map

`OccupationStandard` belongs to a required `RegistrationAgency` and optionally to `Occupation`, `Organization`, and `Industry`. It owns ordered `WorkProcess`, `RelatedInstruction`, and `WageStep` records. A work process owns ordered `Competency` records.

Important `OccupationStandard` fields include `title`, `rapids_code`, `onet_code`, `ojt_type`, OJT/RSI hour ranges, `national_standard_type`, `source`, `status`, registration dates, and its stable UUID. Sources are `manual_upload`, `rapids_api`, `onet_api`, and `ai_conversion`.

Document provenance has two paths:

```text
StandardsImport or another parent
  -> Import STI tree (Uncategorized/Doc/Docx/DocxListing/Pdf)
       -> DataImport -> OccupationStandard       # spreadsheet/manual import
       -> OpenAIImport -> OccupationStandard     # AI PDF conversion
```

- `Import` is STI and belongs to a polymorphic parent. Source files ultimately resolve to an `Imports::Pdf` leaf; Active Storage owns the actual file.
- `DataImport` belongs optionally to an `Imports::Pdf`, an `OccupationStandard`, and a user. It is not the provenance link for an AI-created standard.
- `OpenAIImport` belongs to the source `Import`, stores raw/parsed responses and extraction errors, and optionally belongs to the generated standard.
- A PDF can own several `open_ai_imports`, one per extracted occupation. Each links to its own AI standard. Use `Import#ai_import_for(standard)` to select a comparison by occupation; the legacy singular `open_ai_import` alone does not describe the whole PDF.
- An AI-created standard can therefore have no `data_imports` and still have valid source provenance through `open_ai_import`.
- Use `OccupationStandard#source_imports`, `#source_documents`, and `#source_urls` when presenting provenance. Public visibility can be inherited from either the PDF import or its root; use `#public_document?`/`#public_source_document` rather than assuming a `DataImport` exists.
- Database foreign keys protect referenced rows, but optional associations allow incomplete historical records. Diagnose missing provenance rather than inventing links.

Be cautious with deletion or deduplication. Public/admin URLs contain occupation-standard UUIDs and may be referenced externally. Prefer updating a matched standard and replacing owned child data transactionally over deleting/recreating the standard. Before treating `rapids_code` as a database-unique key, inspect real duplicates and scope: it identifies the reference occupation, while multiple sponsor standards may legitimately share it.

## Ingestion pipelines

### RAPIDS reference occupations and O*NET

- `occupation:rapids_codes_scraper` runs `ScrapeRAPIDSCode`. It downloads the federal apprenticeship occupation workbook and updates `Occupation` reference records with RAPIDS code, O*NET relationship, and expected time/competency/hybrid hours.
- `occupation:onet_code_scraper` runs `ScrapeOnetCodes`. It refreshes current-version `Onet` records and calls `OnetWebService` for related data.
- Both rake tasks run only on Sunday unless `FORCE=true`. That guard does not schedule them; check the deployed scheduler separately before stating how often production invokes them.
- `Onet::CURRENT_VERSION` and mappings between releases matter. Do not flatten O*NET codes to SOC-only values inside the application model; reporting may deliberately remove the decimal suffix.

### RAPIDS occupation standards

- `rapids:import_data` enqueues `ImportDataFromRAPIDSJob` on Monday, or with `FORCE=true`. Again, an external scheduler must invoke the rake task.
- The job pages through RAPIDS work-process responses, maps each payload through `RAPIDS::OccupationStandard`, builds `RAPIDS::WorkProcess` children for a new record, fetches the source document when available, and links it through a completed `DataImport`.
- Current matching behavior in `RAPIDS::OccupationStandard` is code that must be inspected carefully before refresh work. A holistic refresh should preserve the existing `OccupationStandard` UUID, update mutable attributes and owned children transactionally, retain provenance, and be idempotent.
- The PDF/source document is the best authority for what the approved standard says. RAPIDS is authoritative for the current API representation and may disagree with that document. Surface and audit meaningful conflicts—especially OJT type/hours—instead of silently choosing one source.

### Spreadsheet/manual imports

`ProcessDataImportJob` drives the legacy structured import path. It calls the detail, related-instruction, wage-schedule, and work-process import services, marks the standard in review, then reloads it and updates Elasticsearch. Changes here can affect child replacement, counters, provenance, and search indexing.

### Uploaded source documents and scrapers

State/bulletin scrapers create import trees and enqueue processing. `scraper:states` is Sunday-gated and queues the individual scraper jobs. `Imports::Doc`/`Docx` convert to PDF; `DocxListing` fans out; `Imports::Uncategorized` classifies a child. Keep import-tree parentage, `public_document`, metadata, status, and Active Storage attachments intact.

Word files can contain embedded Word, Excel, or PDF documents that LibreOffice renders only as icons. `ExtractEmbeddedDocuments` recovers payloads; `AppendEmbeddedDocumentsToPdf` converts and appends them. This needs LibreOffice and `pdfunite` from `poppler-utils`. Inspect the source and resulting PDF before calling a conversion complete. Repair an existing PDF attachment through `RepairEmbeddedImportPdf`; do not reprocess its Word parent casually, because that creates a new PDF import. The user's preference is direct replacement without retaining PDF backups. See `docs/embedded-document-repair.md`.

## AI PDF extraction

The active flow is:

```text
Imports::Pdf
  -> PdfReaderJob
  -> ConvertPdfImportWithAI
  -> PdfTextExtractor (pdftotext -layout, PDF::Reader fallback)
  -> ChatGptGenerateText + OpenAIPrompt.default
  -> parsed JSON and validation
  -> OpenAIImport
  -> OccupationStandard and child records only when validation succeeds
```

Current implementation details to re-check before experiments:

- `ChatGptGenerateText` currently uses `gpt-4o-mini`, temperature zero, through the chat API.
- The editable/default prompt is stored in `OpenAIPrompt`, not only in source code.
- Changing `OpenAIPrompt::DEFAULT_PROMPT` alone does not update an existing database default. `open_ai_prompts:create_default` activates the code-defined prompt; check the current default and evaluate a candidate before replacing it.
- `ConvertPdfImportWithAI` accepts an `occupations` array, normalizes common response-key variants, resolves OA/SAA registration agencies, and persists separate processes/competencies/related instruction for each occupation. Inventory-only multi-occupation responses, missing title/OJT type, unresolved agency, duplicate sections, and incomplete document counts remain validation/review cases. Valid sibling occupations can still be saved.
- Every attempted conversion stores an `OpenAIImport`, including extraction errors. A standard is saved and linked only when its validation succeeds. Explicit `force` retries clear failed attempts and refresh safely matched AI standards in place, retaining UUIDs; manual/RAPIDS standards must not be overwritten. Normal calls reuse stored results. Job warnings and the admin import's `ai_conversion_errors` expose failures.
- Layout loss during PDF-to-text conversion is a major potential error source. Diagnose extracted text, prompt/model output, normalization, and persistence separately.
- A genuinely separate occupation needs its own attributable schedule or occupational objective. Repeated titles, alternate titles, and stale template footers are not sufficient evidence. Preserve continuation rows and report unresolved boundaries. Flat competency rows must not be duplicated as invented child competencies.
- `MatchAIOccupation` selects the correct source result; `PersistAIOccupation` updates safely matched AI records and owned children. Appendix/program context matters when occupations share a code or title. Preserve ambiguous previous records for review rather than guessing or deleting their UUIDs. See `docs/multi-occupation-extraction.md`.

Treat extraction improvement as an evaluation problem, not prompt guesswork:

1. Compare expected and generated values field-by-field on a fixed sample.
2. Classify failures (source text loss, selection, schema/normalization, hallucination, or persistence).
3. Change one layer at a time and retain it only if the aggregate result improves without unacceptable OA/SAA regressions.
4. Report exact-value and structural metrics, plus important semantic errors such as OJT hours/type and missing processes or competencies.
5. Use a representative OA and SAA holdout before calling a change general.

Do not replace the architecture solely because one model performs poorly. The highest-impact experiments are usually controlled model comparisons on the same extracted text and prompt, followed by better document/layout input if errors originate before the model.

### CSV benchmarks and sample refreshes

- A local `results.csv` may contain the current benchmark export. Treat it as input data, not a fixture to overwrite or commit. For comparisons, capture its exact standard UUIDs, source files/text, prompt/version, model, and scoring rules. Do not reselect the sample between experiments.
- `OccupationStandardSampleSetScoreReport` produces the eleven-point score CSV ending in `total_percentage`: seven one-point identity/context fields plus two points each for work-process/competency text and related-instruction text. Keep the rubric fixed while measuring extraction changes. High text similarity does not prove correct hours, counts, or hierarchy.
- `OccupationStandardSampleSetReport` is the detailed structural report: processes, competencies, hours, instruction, and mismatch categories. Use it alongside the total percentage and direct PDF review.
- `FORCE=true DRY_RUN=true bundle exec rails occupation_standards:enqueue_sample_ai_conversions` previews refreshes, including previously converted PDFs. Remove `DRY_RUN=true` only for an intended run. `COUNT` limits source PDFs, not occupation-standard rows; one PDF can produce several standards. Omitting `COUNT` covers all selected source PDFs; `COUNT=0` explicitly disables a positive limit inherited from the environment. `BASELINE_ONLY=true` deliberately narrows the scope and is not a full-sample evaluation. For an explicit full refresh, set `COUNT=0 BASELINE_ONLY=false`; enqueueing finishes before Sidekiq completes the conversions.
- Export scores with `bundle exec rails 'occupation_standards:sample_set_score_report[tmp/sample-scores.csv]'`; export detailed metrics with `bundle exec rails 'occupation_standards:sample_set_report[tmp/sample-structure.csv]'`. Check the exported UUID set against the fixed benchmark. The tasks use current `sample_set` membership, which can differ from an older CSV.
- Use explicit forced refreshes to preserve matched AI standard UUIDs. `occupation_standards:reset_sample_ai_conversions` deletes records and is not the routine prompt-evaluation workflow.
- Distinguish missing conversions, wrong occupation pairing, reference-link failures, formatting differences, missing baseline fields, and genuine PDF/RAPIDS conflicts. Preserve printed RAPIDS suffixes and legacy occupation `SYMBOL` codes; do not mistake state program numbers, `MA#`, or `WSATC` identifiers for occupation codes. Do not copy expected baseline values into extraction solely to improve the score.
- Keep benchmark exports, evaluation scripts, inputs, responses, and dated results under ignored `tmp/`. Put a short dated summary and artifact paths in the local session handoff, not evolving score tables or private record IDs in this guide.

## Search, background work, and operations

- Elasticsearch backs occupation and occupation-standard search; the documented development version is 8.10.3. Feature flags select some Elasticsearch versus SQL paths. Keep index mappings, eager loading, and fallback behavior in mind.
- A raw PostgreSQL restore does not synchronize Elasticsearch. `bin/pull_production_database` now invokes the development-only `development:reindex` task after a successful restore: it restores synonyms, force-rebuilds both search indexes, and checks bulk errors/counts. Elasticsearch must already be running. If indexing fails, the database remains restored; retry the task using the printed connection settings instead of pulling again. See `docs/development-elasticsearch.md`. Missing search documents can cause an `after_commit` indexing error after conversion data has already persisted. Inspect stored results and restore the local index before repeating paid AI calls; saved responses can be replayed for persistence verification.
- Occupation-standard pages can be query-heavy. Avoid per-row calls to `open_ai_import`, imports, work processes, competencies, registration agency/state, or organization without appropriate preloading. Bullet is enabled in tests to catch these regressions.
- Preloading a singular association does not populate its plural association's cache. When import rendering reads `open_ai_imports`, update parent collection scopes too: `Admin::StandardsImportsController` renders nested imports after edits/uploads and must preload `imports: :open_ai_imports`, independently of `Admin::ImportsController`.
- Sidekiq runs Active Job work. The general `worker` consumes `default` with three threads. `PdfReaderJob` uses `ai_conversion`, consumed by a separate `aiworker` process through `ruby bin/ai-worker`. `AI_CONVERSION_CONCURRENCY` defaults to 10 and the launcher sets its process-local `RAILS_MAX_THREADS` to match the database pool. Both deployment workflows and container release validation include the AI worker image. Enable its dyno after deployment; publishing an image alone does not scale it up. Already serialized jobs retain their old queue. See `docs/ai-workers.md` for rollout, backlog, and capacity guidance.
- Redis configuration should use `REDIS_URL` directly. Do not reintroduce indirection through `REDIS_PROVIDER` without a demonstrated need.
- Image processing requires the `ruby-vips` gem and the system `libvips` library. Both CI and the runtime image need the native package.
- New Relic, router logs, and error reporting are diagnostic evidence. For Heroku H12/H14 or memory incidents, correlate slow transactions, SQL/query counts, GC, dyno memory, external calls, and queue load before tuning concurrency.

Deployment-specific names, credentials, IDs, and private operational notes do not belong here. Put local-only context in `tmp/codex-context.md`; `tmp/` and `codex_resume.sh` are gitignored.

## Session continuity

- During every substantive work session, maintain this guide with critical durable behavior, commands, decisions, and pitfalls discovered in current code. Consolidate existing guidance and remove superseded facts rather than appending a session transcript. Do not manufacture updates when nothing durable changed.
- Before handing work back, refresh `tmp/codex-handoff.md` with a date, completed work, validation and its scope, local versus deployed state, remaining work, and paths to important artifacts. Keep machine-specific/private operational facts in the small `tmp/codex-context.md`. Neither file may contain credentials, signed storage URLs, dumps, or personal data.
- `codex_resume.sh` starts Codex at the repository root and loads the local operational context and dated handoff when present. Keep that startup process aligned with these files; put evolving session facts in the handoff rather than embedding a growing history in shell code.
- At a fresh start, read `tmp/codex-context.md` and `tmp/codex-handoff.md` when present and not already supplied by the launcher, then inspect `git status` and current implementation. Treat dated counts, prompt activation, database synchronization, deployment state, and test results as historical evidence to verify when relevant, not permanent facts or authorization for remote actions.

Shared application hosts:

- Local public: `http://example.localhost:3000`
- Local admin: `http://admin.example.localhost:3000`
- Production public: `https://apprenticeshipstandards.org`
- Production admin: `https://admin.apprenticeshipstandards.org`

## Working in this repository

- Preserve unrelated local changes. Inspect `git status` before editing.
- Prefer focused fixes backed by a regression spec. Run the narrow spec first, then the relevant group or full suite when requested.
- The local PostgreSQL role commonly needs `POSTGRES_USER=ck`, for example: `POSTGRES_USER=ck bundle exec rspec path/to/spec.rb`.
- Elasticsearch should be running for search/system specs. Do not assume a container is required if the host service is available.
- Run `bundle exec standardrb <changed Ruby files>` and relevant specs. ERB uses `bundle exec erb_lint`.
- CI runs `after_party:generate_synonym_set` before RSpec, leaving a persisted UX synonym. Specs that need an exact or empty synonym table must isolate their rows inside the example transaction rather than assume an empty database.
- Use Rails models/services and transactions for data repair. Default to a dry run, print counts and reasons, make targeting explicit, and make production tasks idempotent.
- Never commit exports, production data, credentials, signed object-storage URLs, app names the user considers sensitive, or files under `tmp/`.
- For factual questions about existing behavior, inspect and explain first; do not change code unless asked.

## Where to look first

- Domain model: `app/models/occupation_standard.rb`, `occupation.rb`, `onet.rb`, `registration_agency.rb`
- Import provenance: `app/models/import.rb`, `app/models/imports/`, `data_import.rb`, `open_ai_import.rb`
- RAPIDS: `app/jobs/import_data_from_rapids_job.rb`, `app/models/rapids/`, `app/services/rapids/`, `lib/tasks/rapids.rake`
- Reference catalogs: `app/services/scrape_rapids_code.rb`, `scrape_onet_codes.rb`, `onet_web_service.rb`, `lib/tasks/occupation.rake`
- AI extraction: `app/jobs/pdf_reader_job.rb`, `app/services/convert_pdf_import_with_ai.rb`, `match_ai_occupation.rb`, `persist_ai_occupation.rb`, `pdf_text_extractor.rb`, `chat_gpt_generate_text.rb`
- Benchmarks: `app/services/occupation_standard_sample_set_score_report.rb`, `occupation_standard_sample_set_report.rb`, `lib/tasks/occupation_standard_sample.rake`; full refresh runbook: `docs/ai_sample_set_report.md`; extraction architecture: `docs/multi-occupation-extraction.md`
- Structured import: `app/jobs/process_data_import_job.rb`, `app/services/import_occupation_standard_*`
- Schema truth: `db/schema.rb`; deployment history and repairs: `db/migrate/` and `lib/tasks/deployment/`
- Search: `app/models/concerns/elasticsearchable.rb`, query objects, and occupation-standard controllers/views
