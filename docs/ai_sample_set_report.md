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

Preview the selection:

```sh
heroku run --app apprenticeship-standards-dot-o 'DRY_RUN=true SAMPLE_SIZE=500 SAMPLE_SEED=2026-08-19 bin/rails occupation_standards:select_sample'
```

Reset and select the sample:

```sh
heroku run --app apprenticeship-standards-dot-o 'SAMPLE_SIZE=500 SAMPLE_SEED=2026-08-19 bin/rails occupation_standards:select_sample'
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

## Notes

- Use a fixed `SAMPLE_SEED` to make sample selection reproducible.
- The report reads AI extraction data from the source PDF's `OpenAIImport`.
- Re-running the enqueue task skips source PDFs that already have an
  `OpenAIImport`.
