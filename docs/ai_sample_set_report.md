# AI Sample Set Report

This report compares manually imported occupation standards against AI extraction
from the same source PDF.

## Simplified admin report

The admin index's `Sample CSV Report` downloads an automatic comparison score.
The existing detailed report remains accessible directly at
`/admin/occupation_standards/sample_set_report.csv?full=true`, without a UI link.
The sample report link retains the current filters and restricts results to the sample set.
`sample_set_score_report` generates this eleven-point format; `sample_set_report`
generates the detailed structural report.

The simplified CSV identifies the selected standard by its admin URL (`id`) and
includes the baseline title, registration-agency name, and linked source scope,
followed by nine numeric scoring columns. The `title` column is the title match
score. The baseline title is blank when no unambiguous baseline is available.

- Title, O*NET code, RAPIDS code, source document, occupation, OJT type, and
  registration agency: one point each when present and matching; otherwise zero.
- Work processes and instructions: zero for missing AI content, one for present
  but differing content, and two for matching content. Both absent earns two
  points as not applicable.

`total_percentage` is `total_points / 11 * 100`, rounded to two decimals.
Missing successful conversions or unambiguous baselines receive zero points.
For a shared multi-occupation PDF, each baseline is compared to its matching AI
occupation result. AI-selected rows use the matching non-AI standard linked to
the source PDF; ambiguous associations are not guessed.

Fuzzy title/content matching uses case-insensitive unique alphanumeric tokens
with intersection / union similarity of at least 80%. Work-process text includes
competencies, and instruction text includes descriptions. Counts, ordering,
and grouping do not need to match. Codes and OJT type match after trimming and
ignoring case; registration agency IDs match (including state). Occupation
matches by reference ID or fuzzy title. Source-document credit requires the
conversion to use the baseline's same attached PDF, establishing shared source
provenance and root URL.

These scores estimate agreement with stored RAPIDS/manual data. They do not
verify PDF accuracy or resolve conflicts between the baseline and PDF, and token
overlap cannot reliably detect every semantic difference.

AI conversion uses layout-preserving `pdftotext -layout` output when the
command is available. It falls back to `PDF::Reader` text extraction when
`pdftotext` is unavailable or returns blank text.

## Selection criteria

Select a benchmark once and keep its standard UUIDs fixed across extraction
iterations. Do not reselect the sample as part of a routine rerun. When explicitly
creating a new benchmark, the selection task chooses standards that:

- have `sample_set` set to `true` by the selection task
- have persisted work processes
- have an associated `DataImport`
- have that `DataImport` linked to an `Imports::Pdf` with an attached source PDF
- have no direct `OpenAIImport`
- have no `OpenAIImport` on the associated source PDF

The default sample size is 500.

## Rerunning AI conversions for the existing sample

This refreshes the AI comparisons for the current `sample_set` records, including
previous successes and failures. It updates safely matched AI standards in place
and retains their UUIDs; it does not overwrite RAPIDS/manual baselines. New
occupations discovered in a shared PDF can create additional AI standards.

No additional source changes or migration are needed once the latest extraction
code is deployed. Ensure both web and Sidekiq workers use that release. Set
`PRODUCTION_APP` in your shell to the production application name.

### 1. Activate the deployed prompt

The default prompt is a database record. Deploying changes to
`OpenAIPrompt::DEFAULT_PROMPT` alone does not activate them. Run:

```sh
heroku run --exit-code --app "$PRODUCTION_APP" 'bundle exec rails open_ai_prompts:create_default'
```

### 2. Preview the full refresh

```sh
heroku run --exit-code --app "$PRODUCTION_APP" 'FORCE=true DRY_RUN=true COUNT=0 BASELINE_ONLY=false bundle exec rails occupation_standards:enqueue_sample_ai_conversions'
```

Confirm the source PDF count and that the current sample still contains the
intended baseline UUIDs. This preview makes no AI calls and enqueues no jobs.

- `FORCE=true` includes previously converted PDFs, not just untouched PDFs.
- `COUNT` limits source PDFs, not occupation-standard rows. One PDF can yield
  several AI standards. `COUNT=0` explicitly removes a positive PDF limit, even
  if one is configured in the environment.
- `BASELINE_ONLY=false` includes the full sample; `true` selects only the narrower
  OA state cohort with one linked baseline standard per PDF.

### 3. Optionally run and review a canary

```sh
heroku run --exit-code --app "$PRODUCTION_APP" 'FORCE=true DRY_RUN=false COUNT=1 BASELINE_ONLY=false bundle exec rails occupation_standards:enqueue_sample_ai_conversions'
```

Wait for its job to finish. Check each occupation's boundaries, registration
context, OJT type/hours, processes, competencies, and related instruction against
the actual PDF before launching the complete refresh.

### 4. Enqueue the full refresh

```sh
heroku run --exit-code --app "$PRODUCTION_APP" 'FORCE=true DRY_RUN=false COUNT=0 BASELINE_ONLY=false bundle exec rails occupation_standards:enqueue_sample_ai_conversions'
```

The command exits after **enqueueing**, not after the conversions finish. Sidekiq
must be running with the updated code. It may retry genuine job exceptions;
validation failures are stored per occupation and logged without necessarily
failing the Sidekiq job. Inspect the admin import's AI conversion errors as well
as worker logs. Valid sibling occupations can persist while another needs review.

Do not use `occupation_standards:reset_sample_ai_conversions` for routine prompt
iterations: that task deletes AI records and their standards. `FORCE=true` is the
UUID-preserving refresh path. Without FORCE, the enqueue task skips PDFs that
already have an AI attempt.

### 5. Export and compare after the queue finishes

Download `Sample CSV Report` from the admin occupation standards index for the
eleven-point report ending in `total_percentage`. Clear unintended search filters
and verify its UUID set matches the original benchmark. The detailed report is
available at `/admin/occupation_standards/sample_set_report.csv?full=true`.

For local CLI exports, with the correct database environment configured:

```sh
bundle exec rails 'occupation_standards:sample_set_score_report[tmp/sample-scores.csv]'
bundle exec rails 'occupation_standards:sample_set_report[tmp/sample-structure.csv]'
```

The tasks also accept `[-]` to write CSV to stdout. A production one-off dyno's
temporary file is ephemeral; use the admin download for production exports rather
than assuming a dyno-local file is available locally.

Keep the original benchmark and new export separate. Check the same standard
UUIDs, source documents, prompt/model, and scoring rules before comparing results.
A partial rerun is not a complete new-prompt evaluation of the full sample.

## Iterating on a subset

Use the same positive COUNT for preview, enqueue, and the corresponding reports
to select a deterministic subset of source PDFs:

```sh
heroku run --exit-code --app "$PRODUCTION_APP" 'FORCE=true COUNT=50 BASELINE_ONLY=false DRY_RUN=true bundle exec rails occupation_standards:enqueue_sample_ai_conversions'
heroku run --exit-code --app "$PRODUCTION_APP" 'FORCE=true COUNT=50 BASELINE_ONLY=false DRY_RUN=false bundle exec rails occupation_standards:enqueue_sample_ai_conversions'
```

To work only on the OA state single-linked-baseline cohort, use
`BASELINE_ONLY=true` consistently for enqueueing and reports. That cohort is a
subset, not the full sample, and one linked baseline does not prove the PDF
contains only one occupation. See the detailed cohort definition below.

## Creating a new benchmark

Only run selection when intentionally establishing a different benchmark. The
selection task resets `sample_set` membership; already-converted source PDFs are
not eligible for normal fresh selection. A seed is reproducible only against an
unchanged eligible dataset, so retaining the actual UUIDs is essential.

```sh
heroku run --exit-code --app "$PRODUCTION_APP" 'DRY_RUN=true SAMPLE_SIZE=500 SAMPLE_SEED=2026-08-19 bundle exec rails occupation_standards:select_sample'
heroku run --exit-code --app "$PRODUCTION_APP" 'DRY_RUN=false SAMPLE_SIZE=500 SAMPLE_SEED=2026-08-19 bundle exec rails occupation_standards:select_sample'
```

For the association model, per-occupation validation, source-code conventions,
and prompt evaluation practices, see [multi-occupation extraction](multi-occupation-extraction.md).

## OA State Single-Occupation Baseline

The report includes `baseline_oa_state_single_occupation` to identify the
target measurement cohort. It is `1` when:

- the original sample-set standard has an OA registration agency
- the original sample-set standard has a state
- the linked source PDF is associated with exactly one occupation standard

The baseline success score is in `score_oa_single_occupation_success`. It is
blank for rows outside the baseline cohort. For baseline rows, it is `100.0`
only when all measured extraction fields match:

- work process names
- work process hours, except competency-based standards where hours are not
  applicable
- competency names
- related instruction titles

The individual exact-match fields are also included:

- `score_wp_names_match`
- `score_wp_hours_match`
- `score_competency_names_match`
- `score_ri_titles_match`

The report also includes the AI model's own document classification fields:

- `ai_document_occupation_count`
- `ai_single_occupation`
- `ai_selected_occupation_title`

Those fields come from the OpenAI parsed response and help distinguish
extraction misses from PDFs the model classified as ambiguous or
multi-occupation.
