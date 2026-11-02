# AI extraction accuracy: gaps and review priorities

The eleven-point report measures agreement with a stored baseline. Source PDF
accuracy, extraction completeness, safe occupation attribution, and agreement with
that baseline are separate questions. Keep benchmark UUIDs, source files, and the
rubric fixed while measuring a change. Report baseline/PDF conflicts explicitly.

Dated measurements and record-level examples belong in ignored evaluation
artifacts, not this guide. The current local assessment is
`tmp/single-occupation-improvement/closeout-2026-11-02.md`; its companion
`closeout-case-examples.md` contains admin links. These files are not distributed
with the repository.

## Current priorities, in order of remaining agreement-point losses

1. **RAPIDS codes and reference fidelity.** Preserve printed occupation suffixes.
   Distinguish occupation codes from sponsor numbers, state program identifiers,
   and hours. A printed suffixed code may legitimately disagree with an API
   baseline's numeric code. Resolve reference associations independently of the
   stored source code: exact code first, unique numeric-base reference next.
   Existing O*NET fallback can also miss a reference when its first code match is
   an older version without associations. The additional fallback uses a unique
   cross-version reference, including an unspecialized `.00` lookup for a printed
   SOC-only code. It does not rewrite the printed O*NET value. Ambiguity remains
   a review case.
2. **Related instruction completeness and boundaries.** Recover actual course
   rows, topics, subordinate curriculum bullets, and continuation pages. Avoid
   short summaries that omit the outline. Also distinguish curriculum from
   administrative attendance, delivery-method, reimbursement, and annual-hours
   requirements. A tested narrative-preservation prompt produced generic course
   records from administrative text and caused regressions. A curriculum-only
   revision remains experimental; representation of general RSI requirements
   needs a consistent product decision and source-reviewed evaluation.
3. **Work-process completeness and source alignment.** Inspect omitted rows,
   collapsed competencies, descriptions, continuation pages, and group boundaries.
   A baseline can contain only a small subset of the actual schedule, or tasks
   absent from the linked PDF. High baseline-token recall with low Jaccard
   similarity can indicate additional content rather than omission. Low source
   token coverage can indicate a mismatched/incomplete baseline or lost PDF text;
   inspect the rendered PDF before deciding.
4. **Registration context.** State-level standards can lose their state during
   extraction. Generic national documents may also fail to establish the program
   state represented by a baseline. Use attributable agency/program evidence and
   `RegistrationAgency.registration_agency_for_state`, including California's
   dual-agency handling. Sponsor location alone does not settle jurisdiction.
5. **Titles and alternate titles.** Separate source titles, aliases, baseline
   codes, revision labels, and approach metadata. Repeated or alternative titles
   do not establish another occupation. Do not strip meaningful specialties or
   manufacture a baseline-style title just to improve token agreement.
6. **Remaining reference occupation links.** Use unambiguous source-code and
   catalog relationships. A broad O*NET code can cover several reference
   occupations; choosing the first row is not evidence that the correct reference
   was selected. Missing baseline links also prevent agreement credit.
7. **OJT approach and required-field failures.** Prefer explicit selected
   approaches and completion provisions. Both text extractors can omit checkbox
   graphics. Required classroom hours and approximate program duration do not
   establish a time-based or hybrid OJL approach. A missing OJT type invalidates
   a proposed conversion even if other fields are useful. Keep source-supported
   repairs separate from guesses and from baseline expectations.
8. **O*NET values and versions.** Preserve printed values, check obsolete or
   specialized codes, and distinguish lookup normalization from changing source
   data. Do not flatten application values to SOC-only codes.
9. **Missing or mismatched conversions.** A failed comparison is not necessarily
   an OJT/content error. Inspect prior AI identities, erroneous program codes,
   multiple attempts, and title variants. Preserve UUIDs and flag uncertain
   matches; do not delete previous standards or bypass guards for a higher score.

The dated assessment ranks these fields by exact lost points and records overlap:
missing conversions contribute losses in several columns and must not be added a
second time.

## Representative patterns

- A CNC machinist source prints an alphabetic RAPIDS suffix that the baseline
  omits. Its reference link can be repaired while preserving the source code.
- A trainer's curriculum has many subordinate topics; storing only broad course
  headings loses content.
- A teacher-aide baseline and its linked PDF contain substantially different
  work-process text; extraction should not invent the missing baseline tasks.
- An optics-technician PDF explicitly checks time-based while its baseline says
  competency-based; changing the AI answer to the baseline would be wrong.
- A nursing-assistant PDF loses its checked box in text extraction, but explicit
  mastery-based completion wording can still support the correct approach.
- A bulletin explicitly states `Type of Training: Hybrid`; deterministic evidence
  extraction recognizes that label without treating a list of all approaches as
  a selection.
- A help-desk PDF has an unrelated historical AI occupation sharing its code;
  refreshing must surface the attribution problem.
- A plastering/plasterer title variant with no occupation code can fail a strict
  match; inspect the source before intentionally preserving/updating its UUID.

## Evaluation and acceptance

1. Pin the original CSV IDs and source/text/prompt hashes. Reserve OA/SAA and
   single/shared-source holdouts before examining model output.
2. Change one layer at a time. Save provider responses, actual model/version,
   reasoning/output settings, usage, validation errors, and retained UUIDs.
3. Replay saved responses through normalization, validation, matching, and
   persistence inside rolled-back transactions before committing a refresh.
4. Report proposed full-sample scores separately from the subset actually
   applied. Do not choose individual outputs simply because they score higher.
5. Inspect regressions, hours, hierarchy, missing fields, and occupation coverage.
   Verified quotes establish textual grounding, not necessarily correct reasoning.
6. Promote a model/prompt only after aggregate and subgroup results justify it.
   A canary improvement is not a full-sample estimate. Keep experimental source
   repair scripts distinct from the normal worker path.

The source-grounded OJT audit is read-only:

```sh
POSTGRES_USER=ck bundle exec rails 'occupation_standards:ojt_audit[benchmark.csv,tmp/ojt-audit.csv]'
```

It downloads source PDFs, makes no AI calls, and changes no database records.
See [the sample-report runbook](ai_sample_set_report.md) and
[production rollout checklist](ai_extraction_production_rollout.md).
