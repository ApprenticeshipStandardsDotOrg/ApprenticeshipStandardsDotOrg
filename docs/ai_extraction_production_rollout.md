# AI extraction production rollout checklist

Deploying code does not regenerate existing AI conversions. Existing records are
reused unless an explicit forced refresh is requested. To apply the conversion
changes to the existing sample, run a controlled `FORCE=true` refresh after
checking the release, prompt, worker, and source scope below.

These are operator instructions; documenting them does not authorize or execute
production operations. Set `PRODUCTION_APP` privately in your shell. Keep exported
production data and record-level manifests outside git.

## 1. Review and deploy the intended change

- [ ] Review source/tests and run the affected regression group, Ruby style, and
  whitespace checks. These extraction changes introduce no database migration.
- [ ] Deploy the web, general worker, and AI-worker images from the same release
  through the repository's normal deployment workflow.
- [ ] Keep the current production model/prompt for this rollout. The GPT-5.4
  comparisons and instruction/curriculum prompt variants remain experimental;
  full-sample regressions and source-repair integration need review before
  production adoption. The application default remains `gpt-4o-mini`.

Inspect release/process state:

```sh
heroku releases --app "$PRODUCTION_APP"
heroku ps --app "$PRODUCTION_APP"
```

## 2. Confirm the dedicated AI worker and runtime settings

Publishing the image does not enable its dyno. If no AI worker is running:

```sh
heroku ps:scale aiworker=1 --app "$PRODUCTION_APP"
```

Keep the general worker running for `default` jobs and any legacy serialized
backlog. New `PdfReaderJob` work uses `ai_conversion`. The AI launcher defaults to
10 threads and sets its process-local database pool; do not increase concurrency
without checking provider limits, memory, and aggregate database connections.

Read only non-secret settings:

```sh
heroku run --exit-code --app "$PRODUCTION_APP" 'bundle exec rails runner '\''puts({model: ENV.fetch("AI_CONVERSION_MODEL", "gpt-4o-mini"), reasoning_effort: ENV["AI_CONVERSION_REASONING_EFFORT"], json_mode: ENV["AI_CONVERSION_JSON"], concurrency: ENV.fetch("AI_CONVERSION_CONCURRENCY", "10")}.inspect)'\'''
```

Confirm the configured API key's organization has credit. The application uses
`CHATGPT_API_KEY`; do not print it or dump all application configuration. A
project-scoped key normally selects its project without an additional project
header. Monthly budget and prepaid credit balance are separate settings.

## 3. Verify the database prompt

Deploying `OpenAIPrompt::DEFAULT_PROMPT` does not activate it in the database.
Conversely, this session's experimental prompt files were not promoted into that
constant or the database default. Do not activate those files for production.

```sh
heroku run --exit-code --app "$PRODUCTION_APP" 'bundle exec rails runner '\''require "digest"; puts({matches_code: OpenAIPrompt.default.prompt == OpenAIPrompt::DEFAULT_PROMPT, prompt_sha256: Digest::SHA256.hexdigest(OpenAIPrompt.default.prompt)}.inspect)'\'''
```

Only when intentionally activating the reviewed code-defined prompt, run:

```sh
heroku run --exit-code --app "$PRODUCTION_APP" 'bundle exec rails open_ai_prompts:create_default'
```

Activation is unnecessary when the intended current database default already
matches the code. Review a mismatch before replacing a potentially newer prompt.

## 4. Capture the baseline and fixed scope

- [ ] Export the current score CSV and detailed structural report before refresh.
- [ ] Preserve their UUID set, source PDFs/blob checksums, active prompt hash,
  runtime model/settings, and current AI UUIDs in a private evaluation manifest.
- [ ] Verify current sample membership against the intended benchmark CSV.
  Report tasks use current membership; they do not automatically read an older
  benchmark's IDs.

These paths are on the one-off dyno:

```sh
heroku run --exit-code --app "$PRODUCTION_APP" 'bundle exec rails "occupation_standards:sample_set_score_report[tmp/sample-before.csv]"'
heroku run --exit-code --app "$PRODUCTION_APP" 'bundle exec rails "occupation_standards:sample_set_report[tmp/sample-structure-before.csv]"'
```

A one-off dyno's filesystem is ephemeral and separate from the next one-off dyno.
Use the admin CSV download or an approved secure artifact-transfer method to
retain reports immediately; a file written by one command will not appear in a
later dyno or in your local `tmp/`. Do not commit reports or expose signed storage
URLs in logs.

## 5. Preview and run a small forced canary

Select a reviewed source PDF manifest covering OA, SAA, single and shared sources,
including a suffix-reference case, an OJT evidence case, and an occupation-match
review case. Keep private IDs out of this checklist. For one approved PDF:

```sh
heroku run --exit-code --app "$PRODUCTION_APP" 'bundle exec rails runner '\''PdfReaderJob.perform_later(import_id: "REPLACE_WITH_APPROVED_PDF_UUID", open_ai_prompt: OpenAIPrompt.default, force: true)'\'''
```

Replace `REPLACE_WITH_APPROVED_PDF_UUID` with the approved source PDF import UUID
before executing. Do not set a permanent app variable just for a canary.
Enqueueing is asynchronous; inspect completion and source-specific errors before
proceeding. Confirm existing AI UUIDs remain intact, manual/RAPIDS standards are
unchanged, and indexing succeeded. A failed attempt can leave persisted data;
inspect results before repeating a paid call.

## 6. Preview the full current sample

```sh
heroku run --exit-code --app "$PRODUCTION_APP" 'FORCE=true DRY_RUN=true COUNT=0 BASELINE_ONLY=false bundle exec rails occupation_standards:enqueue_sample_ai_conversions'
```

Review the source PDF count and UUID scope. `COUNT` limits PDFs, not standard
rows; `COUNT=0` disables an inherited positive limit. `BASELINE_ONLY=true` selects
a narrower OA/state/single subset and is not an all-single-occupation filter.

The command above covers the full current sample, including shared PDFs. For a
single-only rollout, prepare and review an explicit PDF-ID/blob-checksum manifest
and enqueue from that manifest; there is no all-single-only switch on this task.
Do not silently substitute `BASELINE_ONLY=true` or rebuild/reselect the sample.

## 7. Enqueue the approved refresh once

For an intended full-sample refresh after the preview passes:

```sh
heroku run --exit-code --app "$PRODUCTION_APP" 'FORCE=true DRY_RUN=false COUNT=0 BASELINE_ONLY=false bundle exec rails occupation_standards:enqueue_sample_ai_conversions'
```

- [ ] Confirm no duplicate refresh is already queued/running.
- [ ] Allow for one PDF producing multiple AI standards.
- [ ] Do not run `reset_sample_ai_conversions`; routine refresh should preserve
  safely matched UUIDs rather than delete/recreate records.
- [ ] Keep the original model/prompt unless a separately validated change is
  intentionally part of this rollout. Do not run the local ignored experiment
  scripts against production.

## 8. Monitor completion and review failures

```sh
heroku logs --tail --dyno aiworker --app "$PRODUCTION_APP"
heroku ps --app "$PRODUCTION_APP"
```

Check Sidekiq's `ai_conversion` queue, active jobs, retries, and failures using the
existing operational dashboard. Queue-empty alone does not establish completion.
Inspect admin conversion errors, unmatched previous occupations, duplicate
sections, missing OJT types, source changes, memory/database pressure, and provider
quota/rate errors. Stop additional enqueueing if a systematic regression appears.
Do not bypass identity safeguards to improve a comparison score.

## 9. Verify and retain results

```sh
heroku run --exit-code --app "$PRODUCTION_APP" 'bundle exec rails "occupation_standards:sample_set_score_report[tmp/sample-after.csv]"'
heroku run --exit-code --app "$PRODUCTION_APP" 'bundle exec rails "occupation_standards:sample_set_report[tmp/sample-structure-after.csv]"'
```

Retain these exports through the same approved artifact mechanism. Verify the
same UUID set and source inputs, then compare single and multiple groups
separately. Include gains, regressions, unresolved conversions, hours/hierarchy,
and retained AI UUIDs. Do not treat local estimates as deployed accuracy or
baseline/PDF disagreement as proof the AI is wrong.

If an experimental model/prompt regresses, stop further work, restore the previous
approved configuration/default prompt, and review retained responses. Rolling
back application code does not roll back changed conversion records. Use reviewed
UUID-preserving replays or transactional repairs; avoid blanket deletion.

See [AI workers](ai-workers.md), [sample report](ai_sample_set_report.md), and
[accuracy gaps](ai_extraction_accuracy.md).
