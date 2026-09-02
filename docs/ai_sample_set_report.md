# AI Sample Set Report

This report compares manually imported occupation standards against AI extraction
from the same source PDF.

AI conversion uses layout-preserving `pdftotext -layout` output when the
command is available. It falls back to `PDF::Reader` text extraction when
`pdftotext` is unavailable or returns blank text.

## Selection criteria

The sample set is reset before each run. Selected standards must:

- have `sample_set` set to `true` by the selection task
- have persisted work processes
- have an associated `DataImport`
- have that `DataImport` linked to an `Imports::Pdf` with an attached source PDF
- have no direct `OpenAIImport`
- have no `OpenAIImport` on the associated source PDF

The default sample size is 500.

## Production workflow

Deploy the code containing the latest `OpenAIPrompt::DEFAULT_PROMPT` and
extraction changes before running the workflow.

Create a new database prompt from the code-defined default and mark it as the
active default:

```sh
heroku run --app apprenticeship-standards-dot-o 'bin/rails open_ai_prompts:create_default'
```

Preview the selection:

```sh
heroku run --app apprenticeship-standards-dot-o 'DRY_RUN=true SAMPLE_SIZE=500 SAMPLE_SEED=2026-08-19 bin/rails occupation_standards:select_sample'
```

Reset and select the sample:

```sh
heroku run --app apprenticeship-standards-dot-o 'SAMPLE_SIZE=500 SAMPLE_SEED=2026-08-19 bin/rails occupation_standards:select_sample'
```

If the selected sample already has AI conversions from an earlier prompt,
preview the reset:

```sh
heroku run --app apprenticeship-standards-dot-o 'DRY_RUN=true bin/rails occupation_standards:reset_sample_ai_conversions'
```

Delete those AI comparison records. This removes only `OpenAIImport` records
created from sample-set source PDFs and the AI-generated occupation standards
attached to those imports. It does not delete the manually imported sample-set
standards.

```sh
heroku run --app apprenticeship-standards-dot-o 'bin/rails occupation_standards:reset_sample_ai_conversions'
```

Preview AI conversion jobs for the selected sample PDFs:

```sh
heroku run --app apprenticeship-standards-dot-o 'DRY_RUN=true bin/rails occupation_standards:enqueue_sample_ai_conversions'
```

Enqueue AI conversion jobs:

```sh
heroku run --app apprenticeship-standards-dot-o 'bin/rails occupation_standards:enqueue_sample_ai_conversions'
```

After Sidekiq finishes the jobs, download the report from the admin occupation
standards index using `Sample CSV Report`.

Alternatively, stream the CSV from a one-off dyno and redirect it to a local
file:

```sh
heroku run --no-tty --app apprenticeship-standards-dot-o 'bin/rails "occupation_standards:sample_set_report[-]"' > occupation-standards-sample-set-report.csv
```

## Iterating on a Subset

Use `COUNT` with reset, enqueue, and report to iterate against the same
deterministic subset of sample source PDFs. For a 50-PDF pass:

```sh
heroku run --app apprenticeship-standards-dot-o 'bin/rails open_ai_prompts:create_default'

heroku run --app apprenticeship-standards-dot-o 'COUNT=50 DRY_RUN=true bin/rails occupation_standards:reset_sample_ai_conversions'
heroku run --app apprenticeship-standards-dot-o 'COUNT=50 bin/rails occupation_standards:reset_sample_ai_conversions'

heroku run --app apprenticeship-standards-dot-o 'COUNT=50 DRY_RUN=true bin/rails occupation_standards:enqueue_sample_ai_conversions'
heroku run --app apprenticeship-standards-dot-o 'COUNT=50 bin/rails occupation_standards:enqueue_sample_ai_conversions'
```

After Sidekiq drains the 50 conversion jobs, download the subset report:

```sh
heroku run --no-tty --app apprenticeship-standards-dot-o 'COUNT=50 bin/rails "occupation_standards:sample_set_report[-]"' > occupation-standards-sample-set-report-50.csv
```

To iterate only against the target OA state single-occupation baseline cohort,
add `BASELINE_ONLY=true` to reset, enqueue, and report:

```sh
heroku run --app apprenticeship-standards-dot-o 'bin/rails open_ai_prompts:create_default'

heroku run --app apprenticeship-standards-dot-o 'COUNT=50 BASELINE_ONLY=true DRY_RUN=true bin/rails occupation_standards:reset_sample_ai_conversions'
heroku run --app apprenticeship-standards-dot-o 'COUNT=50 BASELINE_ONLY=true bin/rails occupation_standards:reset_sample_ai_conversions'

heroku run --app apprenticeship-standards-dot-o 'COUNT=50 BASELINE_ONLY=true DRY_RUN=true bin/rails occupation_standards:enqueue_sample_ai_conversions'
heroku run --app apprenticeship-standards-dot-o 'COUNT=50 BASELINE_ONLY=true bin/rails occupation_standards:enqueue_sample_ai_conversions'
```

After Sidekiq drains:

```sh
heroku run --no-tty --app apprenticeship-standards-dot-o 'COUNT=50 BASELINE_ONLY=true bin/rails "occupation_standards:sample_set_report[-]"' > occupation-standards-sample-set-report-oa-baseline-50.csv
```

## Notes

- Use a fixed `SAMPLE_SEED` to make sample selection reproducible.
- The report reads AI extraction data from the source PDF's `OpenAIImport`.
- Re-running the enqueue task skips source PDFs that already have an
  `OpenAIImport`. Run `occupation_standards:reset_sample_ai_conversions` before
  re-enqueuing when you want to compare a new prompt or extraction process
  against the same sample.

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
