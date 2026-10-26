Word conversions include the document body and embedded Word, Excel, and PDF
attachments. Legacy DOC ObjectPool objects, DOCX embeddings, OLE Package streams,
and Ole10Native packaged PDFs are supported. LibreOffice converts Word/Excel;
`pdfunite` from `poppler-utils` appends attachments. Unknown object formats fail
visibly rather than producing a PDF that silently omits documents.

Audit existing Word-derived PDF imports linked through either DataImport or
OpenAIImport:

```sh
bundle exec rails documents:audit_embedded
```

The report and extracted payloads are written under `tmp/embedded-document-audit`.
Use `PDF_IDS=id1,id2` for a targeted audit. This scope covers PDFs whose immediate
parent is Imports::Doc or Imports::Docx. It does not audit standalone PDFs, Word
files with externally linked attachments, or missing import provenance.

Review the original PDF and extracted documents. An embedded object alone does
not prove missing content. Where content is missing, prepare a replacement that
retains the original pages and appends the missing attachments. Check conversion
layout, duplicate attachments, and coverage of all linked occupations. Keep
exports and source documents under ignored `tmp/`.

Prepare a JSON array with one entry per reviewed replacement:

```json
[
  {
    "pdf_id": "existing-pdf-import-uuid",
    "replacement_path": "tmp/replacement.pdf",
    "source_sha256": "sha256-of-original-word-file",
    "original_sha256": "sha256-of-current-pdf",
    "replacement_sha256": "sha256-of-reviewed-replacement"
  }
]
```

Run the manifest in dry-run mode first, then apply it:

```sh
MANIFEST=tmp/repairs.json bundle exec rails documents:repair_embedded
MANIFEST=tmp/repairs.json DRY_RUN=false bundle exec rails documents:repair_embedded
```

The repair retains the existing PDF import and standard UUIDs, provenance, status,
visibility, and structured occupation data. It replaces the attachment directly;
the normal Active Storage purge job removes the old PDF when it has no remaining
references. It records file hashes in the import metadata. It
refuses stale files, private/redacted documents, and a second different repair.
Repeating the same manifest returns `already_repaired`.

Production rollout:

1. Merge and deploy the conversion changes, services, tasks, and Dockerfile. The
   runtime must contain LibreOffice and `poppler-utils` (`pdfunite`). No database
   migration is required. Confirm both executables in the deployed image:

   ```sh
   heroku run --app "$PRODUCTION_APP" 'sh -c "soffice --version && pdfunite -v"'
   ```

2. The existing repaired PDFs already contain the recovered attachments. Do not
   reprocess their Word parents: that path creates new PDF imports. For another
   environment or additional cases, use the audit and reviewed replacement
   manifest above, with the files present on the machine running the task.

3. Remove backups retained by the earlier repair, if any. This cleanup has already
   been performed for the production repair; it is safe to repeat and useful in
   another environment. Both commands validate
   the replacement and backup hashes. Apply purges only the old backup attachment;
   a blob referenced elsewhere remains protected by Active Storage's foreign key.

   ```sh
   heroku run --app "$PRODUCTION_APP" 'bundle exec rails documents:remove_repair_backups'
   heroku run --app "$PRODUCTION_APP" 'DRY_RUN=false bundle exec rails documents:remove_repair_backups'
   ```

4. Preview the AI rerun scope. Only repaired PDFs with a prior `OpenAIImport` are
   selected. Manual-only PDFs without a prior AI attempt are excluded. The repair
   inventory had 33 prior attempts: 19 linked AI standards and 14 failed attempts;
   confirm the deployed dry-run output rather than assuming those counts persist.

   ```sh
   heroku run --app "$PRODUCTION_APP" 'COUNT=1000 bundle exec rails documents:reconvert_repaired'
   ```

   This default dry run makes no AI calls. The general `ai_imports:convert` task
   skips already-linked standards, and `force: true` does not refresh successful
   conversions, so neither is a substitute for this targeted task.

5. Choose one reviewed single-occupation PDF from that list and run a canary. Set
   `CANARY_PDF_ID` to its PDF import UUID, not its occupation-standard UUID:

   ```sh
   heroku run --app "$PRODUCTION_APP" "PDF_IDS=$CANARY_PDF_ID COUNT=1 DRY_RUN=false bundle exec rails documents:reconvert_repaired"
   ```

   Review title, RAPIDS/O*NET codes, registration agency, OJT type/hours, work
   processes, competencies, and related instruction against the corrected PDF.
   Check the admin/public standard pages and search results. The canary uses the
   existing default prompt and model; this rollout does not tune extraction.

6. After the canary passes, rerun the remaining attempts sequentially in a
   one-off process. Save and inspect its output:

   ```sh
   heroku run --exit-code --app "$PRODUCTION_APP" 'COUNT=1000 DRY_RUN=false bundle exec rails documents:reconvert_repaired'
   ```

   Successful AI standards are updated transactionally in place, retaining their
   UUIDs, status, and sample-set membership. Work processes/competencies and
   related instruction are replaced; fields outside the current extractor,
   including wage steps, are retained. Standard update callbacks refresh search,
   and the working-copy version changes. Earlier failed attempts can create an
   AI standard when the new extraction passes validation. Manual standards are
   never overwritten.

   Multi-occupation documents now produce separate occupation results; see
   [multi-occupation extraction](multi-occupation-extraction.md). Ambiguous
   identities, incomplete occupation sets, and invalid individual responses
   remain review cases. The latest response/errors are stored on `OpenAIImport`;
   a failed refresh keeps the prior standard data. Do not delete those standards
   or force a multi-occupation document into a single occupation. The task exits
   unsuccessfully if any cases need review, after reporting each result.

7. Verify refreshed data against the source, including an OA and SAA example
   where available. Re-run the preview: successful conversions of the same
   repaired PDF are skipped using its SHA-256 marker. Failed cases remain listed
   until resolved; repeating the apply command retries those failures. Monitor
   extraction errors and search indexing failures before treating the rollout as
   complete.

   If Elasticsearch callbacks fail after the database commit, restore search
   documents for the successful refreshes from a Rails console:

   ```ruby
   ids = OpenAIImport.joins(:import)
     .where("imports.metadata->'embedded_document_repair'->>'ai_conversion_sha256' IS NOT NULL")
     .where.not(occupation_standard_id: nil).pluck(:occupation_standard_id)
   OccupationStandard.where(id: ids).find_each { |standard| standard.__elasticsearch__.index_document }
   ```
