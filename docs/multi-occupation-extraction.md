PDF conversion supports one AI result per occupation, with a shared source PDF.
The prompt returns a document object with an `occupations` array. Each entry has
its own identity, registration context, work processes, competencies, and related
instruction. Repeated references and stale running footers are distinguished
from independently headed occupation schedules; ambiguous output stays visible
for review.

`Import#open_ai_imports` contains the results. Each `OpenAIImport` keeps the complete
provider response and its own normalized occupation in `parsed_response`, and
links to one generated `OccupationStandard`. The existing database already allows
multiple AI imports per PDF, so no migration is needed. The singular association
remains for compatibility; use `ai_import_for(standard)` for comparisons and
`associated_occupation_standards` to list source coverage.

Validation runs separately for each entry. Valid occupations are saved even if a
sibling fails; the PDF is marked for human review and the errors appear on its
admin page and in the job log. Duplicate sections and a declared/extracted count
mismatch prevent the batch from being reported as complete. A forced rerun
refreshes matched AI standards and their children transactionally, retaining
UUIDs and status. It never overwrites manual/RAPIDS standards. Ambiguous matches
are not resolved by picking the first result.

The comparison report now chooses the appropriate occupation within a shared
PDF. Its eleven-point scoring rules and thresholds are unchanged. Matching may
normalize RAPIDS suffixes and recognize unique title aliases for selection; that
does not change extracted codes or award extra score points.

To activate the code-defined prompt in a deployed environment, use the existing
prompt task. Updating the Ruby constant alone does not change the editable
database default:

```sh
bundle exec rails open_ai_prompts:create_default
```

Preview a sample refresh before enqueueing it:

```sh
FORCE=true DRY_RUN=true bundle exec rails occupation_standards:enqueue_sample_ai_conversions
FORCE=true COUNT=1 bundle exec rails occupation_standards:enqueue_sample_ai_conversions
```

Review the canary against the actual source, including agency/state, OJT type and
hours, occupation boundaries, processes, competencies, and instruction. Then omit
COUNT to refresh all PDFs in the current sample. Run Sidekiq with the deployed
code/default prompt. This refresh path preserves AI standard UUIDs; do not use the
destructive sample reset task for routine prompt evaluation.

Export the same eleven-point report format as the current accuracy CSV:

```sh
bundle exec rails 'occupation_standards:sample_set_score_report[tmp/sample-scores.csv]'
```

The reported sample is defined by `sample_set`, with COUNT limiting source PDFs.
For a fixed CSV evaluation, retain its standard IDs explicitly and regenerate
`OccupationStandardSampleSetScoreReport` for those same IDs. Keep inputs,
responses, exports, prompt fingerprints, and analysis under ignored `tmp/`.

Observed accuracy gaps should be classified before changing prompts or scores:

- Missing conversions and incorrect occupation pairing.
- Registration context absent from extraction versus genuine source/API conflicts.
- Missing reference-occupation links and RAPIDS suffix/identifier normalization.
- Program IDs incorrectly extracted as occupation codes; legacy occupation SYMBOL
  headers must remain supported for SAA documents.
- Work-process/competency hierarchy and RTI omissions or text differences.
- Missing baseline fields and presentation metadata in baseline titles.

Use the PDF as the authority for its approved contents. Preserve legitimate code
suffixes and record source/RAPIDS conflicts rather than adjusting source values
solely to increase a comparison score. A high text score does not establish
correct hours or hierarchy; inspect structural and exact-value metrics too.
