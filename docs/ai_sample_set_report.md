# AI Sample Set Report

This report compares manually imported occupation standards against AI extraction
from the same source PDF.

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

After Sidekiq finishes the jobs, generate a fresh report:

```sh
heroku run --app apprenticeship-standards-dot-o 'bin/rails occupation_standards:sample_set_report[tmp/occupation-standards-sample-set-report.csv]'
```

You can also download the same report from the admin occupation standards index
using `Sample CSV Report`.

## Notes

- Use a fixed `SAMPLE_SEED` to make sample selection reproducible.
- The report reads AI extraction data from the source PDF's `OpenAIImport`.
- Re-running the enqueue task skips source PDFs that already have an
  `OpenAIImport`. Run `occupation_standards:reset_sample_ai_conversions` before
  re-enqueuing when you want to compare a new prompt or extraction process
  against the same sample.
