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
- `ConvertPdfImportWithAI` normalizes common response-key variants, resolves OA/SAA registration agencies, builds processes/competencies/related instruction, and rejects clear failures such as multiple occupations, missing title/OJT type, or unresolved agency.
- Every attempted conversion stores an `OpenAIImport`, including extraction errors. A standard is saved and linked only when validation succeeds. `force` clears only a failed attempt with no linked standard; it must not overwrite a successful conversion casually.
- Layout loss during PDF-to-text conversion is a major potential error source. Diagnose extracted text, prompt/model output, normalization, and persistence separately.

Treat extraction improvement as an evaluation problem, not prompt guesswork:

1. Compare expected and generated values field-by-field on a fixed sample.
2. Classify failures (source text loss, selection, schema/normalization, hallucination, or persistence).
3. Change one layer at a time and retain it only if the aggregate result improves without unacceptable OA/SAA regressions.
4. Report exact-value and structural metrics, plus important semantic errors such as OJT hours/type and missing processes or competencies.
5. Use a representative OA and SAA holdout before calling a change general.

Do not replace the architecture solely because one model performs poorly. The highest-impact experiments are usually controlled model comparisons on the same extracted text and prompt, followed by better document/layout input if errors originate before the model.

## Search, background work, and operations

- Elasticsearch backs occupation and occupation-standard search; the documented development version is 8.10.3. Feature flags select some Elasticsearch versus SQL paths. Keep index mappings, eager loading, and fallback behavior in mind.
- Occupation-standard pages can be query-heavy. Avoid per-row calls to `open_ai_import`, imports, work processes, competencies, registration agency/state, or organization without appropriate preloading. Bullet is enabled in tests to catch these regressions.
- Sidekiq runs Active Job work. The Procfile currently starts `bundle exec sidekiq -c 3`; concurrency is deliberately bounded because PDF/document/AI jobs and Rails processes can consume substantial memory.
- Redis configuration should use `REDIS_URL` directly. Do not reintroduce indirection through `REDIS_PROVIDER` without a demonstrated need.
- Image processing requires the `ruby-vips` gem and the system `libvips` library. Both CI and the runtime image need the native package.
- New Relic, router logs, and error reporting are diagnostic evidence. For Heroku H12/H14 or memory incidents, correlate slow transactions, SQL/query counts, GC, dyno memory, external calls, and queue load before tuning concurrency.

Deployment-specific names, credentials, IDs, and private operational notes do not belong here. Put local-only context in `tmp/codex-context.md`; `tmp/` and `codex_resume.sh` are gitignored.

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
- Use Rails models/services and transactions for data repair. Default to a dry run, print counts and reasons, make targeting explicit, and make production tasks idempotent.
- Never commit exports, production data, credentials, signed object-storage URLs, app names the user considers sensitive, or files under `tmp/`.
- For factual questions about existing behavior, inspect and explain first; do not change code unless asked.

## Where to look first

- Domain model: `app/models/occupation_standard.rb`, `occupation.rb`, `onet.rb`, `registration_agency.rb`
- Import provenance: `app/models/import.rb`, `app/models/imports/`, `data_import.rb`, `open_ai_import.rb`
- RAPIDS: `app/jobs/import_data_from_rapids_job.rb`, `app/models/rapids/`, `app/services/rapids/`, `lib/tasks/rapids.rake`
- Reference catalogs: `app/services/scrape_rapids_code.rb`, `scrape_onet_codes.rb`, `onet_web_service.rb`, `lib/tasks/occupation.rake`
- AI extraction: `app/jobs/pdf_reader_job.rb`, `app/services/convert_pdf_import_with_ai.rb`, `pdf_text_extractor.rb`, `chat_gpt_generate_text.rb`
- Structured import: `app/jobs/process_data_import_job.rb`, `app/services/import_occupation_standard_*`
- Schema truth: `db/schema.rb`; deployment history and repairs: `db/migrate/` and `lib/tasks/deployment/`
- Search: `app/models/concerns/elasticsearchable.rb`, query objects, and occupation-standard controllers/views
