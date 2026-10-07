# Test and deployment performance

RSpec runs on two GitHub Actions runners, each with its own PostgreSQL and
Elasticsearch services. `bin/rspec-shard` balances whole spec files using
`config/rspec_runtimes.json`. Every spec file is assigned exactly once; new files
receive a default weight until their runtimes are recorded. The aggregate
`rspec` job preserves the existing required check and fails if either shard fails.

CI caches Bundler dependencies, Yarn downloads, and compiled test assets. The
asset cache includes application/configuration inputs and dependency lockfiles
in its key. Superseded PR runs are canceled. Each shard publishes its RSpec JSON
report and reports execution time in the workflow summary.

Run a single shard with:

```sh
bin/rspec-shard 1 2 --profile 20
```

Concurrent local shards require separate test databases and Elasticsearch
endpoints. Running both against the default services is unsafe: the test hooks
delete shared indexes and synonym sets. CI isolates these services by runner.

Record a serial profile with:

```sh
bundle exec rspec spec --seed 56666 --profile 20 \
  --format progress --format json --out tmp/rspec-results.json
```

Refresh weights from a complete serial report or both shard reports:

```sh
ruby -rjson -e '
  weights = Hash.new(0.0)
  ARGV.each do |path|
    JSON.parse(File.read(path)).fetch("examples").each do |example|
      file = example.fetch("id").split("[", 2).first.delete_prefix("./")
      weights[file] += example.fetch("run_time")
    end
  end
  puts JSON.pretty_generate(weights.sort.to_h.transform_values { |value| value.round(3) })
' tmp/rspec-results.json > config/rspec_runtimes.json
```

Use example IDs rather than definition locations: shared examples and Swagger
examples can have definition locations outside their owning spec file.

Deployment builds the application once with BuildKit's GitHub Actions cache and
publishes web, worker, and release images to GHCR. The images share application
layers and differ in their commands. Staging and production receive the same
digest-pinned images through Heroku Container Registry. The release image runs
migrations and After Party tasks; the workflow waits for the release phase to
succeed before allowing production deployment, including on retries that reuse
the existing release. Images carry the source commit revision. Existing
environment gates and notifications remain in place.

The workflow needs GitHub Packages enabled and its declared `packages: write`
permission for the build job. It uses `GITHUB_TOKEN` for GHCR and the existing
environment-specific `HEROKU_API_KEY` for Heroku. Heroku requires Docker manifest
media types, so image exports disable OCI media types and attestations.

The Dockerfile shares runtime package installation across stages, copies a
pinned Node/Yarn installation from the Node image, and installs Ruby dependencies
before copying JavaScript lockfiles. `.dockerignore` allows only production
inputs. Node modules are cached during asset building and excluded from the
runtime image. Worker concurrency stays at three.

To deliberately refresh cached OS packages, invalidate the deployment cache
scope or use BuildKit's `--no-cache-filter runtime`. Dependency lockfile and base
image changes invalidate their corresponding layers automatically.

## Local benchmark

Measured with seed 56666 and CI eager loading enabled. Test times include process
startup and execution, using already prepared databases and assets. The parallel
run used separate databases and Elasticsearch endpoints on the same machine.

| Measurement | Before | After |
| --- | ---: | ---: |
| Serial versus two-shard test wall time | 117.56 s | 71.36 s |
| Cold Docker build, cache disabled | 229.91 s | 209.32 s |
| Unchanged cached Docker rebuild | No cache on Heroku | 1.01 s |
| Source-only change with a warm Docker cache | No cache on Heroku | 38.66 s |

All 966 original examples were covered exactly once. The parallel run also
included twelve infrastructure regression examples: 978 examples, zero failures,
and seven existing pending examples.

Docker measurements used Linux amd64, BuildKit, and local image loading. Registry
uploads/downloads, GitHub runner/service setup, cache transfers, and Heroku
migrations are outside these measurements. These are local samples, not promised
deployment times. Raw reports and build logs remain under `tmp/`.
