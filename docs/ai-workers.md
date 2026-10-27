# AI conversion workers

`PdfReaderJob` enqueues on `ai_conversion`. The `aiworker` process runs only that
queue, with 10 threads by default. The general `worker` runs `default` with three
threads for scrapers, document conversion, and other jobs. Both Procfile and
container deployment paths define these processes; CI publishes and releases a
separate `aiworker` image from the same application layers.

Run locally with `POSTGRES_USER=ck ruby bin/ai-worker` alongside the general
worker. Set `AI_CONVERSION_CONCURRENCY=20` to change AI threads per process.
The launcher sets `RAILS_MAX_THREADS` inside that process to the same value so
the database pool follows concurrency without changing web or general workers.
Database URL pool parameters, if configured, must also accommodate this value.

## Rollout and existing jobs

Deploy the code and enable at least one `aiworker` dyno before enqueueing new
conversions. Publishing the new image does not itself scale the process up.
After deployment, use `heroku ps:scale aiworker=1 --app <app>` for the intended
environment. Change threads using
`heroku config:set AI_CONVERSION_CONCURRENCY=20 --app <app>`; scale the process
count independently with `ps:scale aiworker=2`. These are operator commands,
not actions performed by this change.

Jobs already queued, scheduled, or retrying keep their serialized `default`
queue. Leave the general worker running to drain them. The queue change does
not accelerate that existing backlog. Do not enqueue a second forced sample
refresh while the first is pending: that would repeat paid API calls. If the
current backlog must be accelerated immediately, plan an explicit targeted
queue migration with workers quieted; do not bulk move the default queue,
which also contains unrelated jobs.

## Throughput and capacity

Ten threads is a starting configuration, not a measured optimal value. With
network wait dominating, it permits up to ten concurrent conversions per AI
process instead of sharing three threads with all jobs. PDF extraction and
database persistence still consume CPU and memory. Increase concurrency in
steps after observing queue latency, completed PDFs per minute, job duration,
memory/GC, database connections, and API throttling/retries. Watch extraction
review errors separately from Sidekiq failures.

Budget connections across all processes: each AI worker has a pool equal to
its thread count, in addition to general workers, web processes, and operational
connections. Provider token/request limits may cap throughput before thread
capacity does. Sidekiq retries failed jobs; avoid increasing threads further
when throttling or database contention is already growing.

See [Sidekiq's concurrency and queue documentation](https://github.com/sidekiq/sidekiq/wiki/Advanced-Options)
and the [sample refresh runbook](ai_sample_set_report.md).
