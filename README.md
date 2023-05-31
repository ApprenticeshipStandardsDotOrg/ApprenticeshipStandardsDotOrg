# ApprenticeshipStandards.org
The ApprenticeshipStandards.org application is currently running on Ruby 3,
Rails 7, and PostgreSQL 14.

## Development setup
1. Run `bin/setup`
2. Install [libvips][libvips] for use with ActiveStorage
3. Install [mailcatcher][mailcatcher] to preview emails. See the
   [troubleshooting](#mailcatcher-troubleshooting) section if you have
   installation issues.
4. To access the admin pages, you must modify your `/etc/hosts` file:
   ```
   # Added for ApprenticeshipStandards.org
   127.0.0.1 admin.example.localhost
   # End ApprenticeshipStandards.org additions
   ```
5. Start rails app: `bin/dev`. The application will be available
   at http://localhost:3000. The admin pages will be available at:
   http://admin.example.localhost:3000.
6. Run mailcatcher:
   ```bash
   mailcatcher
   ```
   To preview emails, go to `http://localhost:1080`

[libvips]: https://www.libvips.org/install.html
[mailcatcher]: https://mailcatcher.me

### Mailcatcher troubleshooting
If you run into an issue while installing mailcatcher, you can try installing thin with the following command:

```bash
gem install thin -v 1.5.1 -- --with-cflags="-Wno-error=implicit-function-declaration"
```

Then, try to install mailcatcher again:

```bash
gem install mailcatcher
```

You can also install mailcatcher with [brew][mailcatcher_brew]:

```bash
brew install mailcatcher
```

[mailcatcher_brew]: https://formulae.brew.sh/formula/mailcatcher

## Staging access
The public staging site is available at: https://staging.apprenticeshipstandards.org<br>
The admin staging site is available at: https://staging-admin.apprenticeshipstandards.org

The current credentials for the public staging site are:

Username: ApprenticeshipStandardsAdmin<br>
Password: Pipe Fitter

These values are set in the `BASIC_AUTH_` environment variables on the staging
app in Heroku.

## Deployment
We have a Heroku pipeline set up with a staging and a production app. The
staging and production remotes can be added locally as follows:

```
git remote add staging https://git.heroku.com/apprenticeship-standards-stag.git
git remote add production https://git.heroku.com/apprenticeship-standards-dot-o.git
```

### Staging
The staging app will be deployed automatically any time code is merged to the
`main` branch.

### Production
Once code changes have gone through QA on staging, the changes can be deployed
to production by promoting the app:

```
heroku pipelines:promote -r staging
```

or

```
heroku pipelines:promote -a apprenticeship-standards-stag
```

If you name your staging remote something other than "staging", then be sure to
replace "staging" with the name of your remote if using the `promote -r`
command.

The promotion can also be done through the Heroku Dashboard on the [Pipelines page](https://dashboard.heroku.com/pipelines/3657e91f-455e-4fa7-9da7-f6ddc1beb854).

## AWS Setup
If you will have access to AWS to manage the S3 buckets, [view the setup
documentation](doc/AWS.md).

## Linting
### Ruby linting

We are using [standard][standard] for Ruby
linting. To check the style of all Ruby files, run:

```
bundle exec standardrb
```

To automatically apply linting fixes, run:

```
bundle exec standardrb --fix
```

### ERB linting
We are using [erb_lint][erb_lint] for ERB linting. To check the style of all
`.erb` files, run:

```
bundle exec erblint --lint-all
```

[standard]: https://github.com/testdouble/standard
[erb_lint]: https://github.com/Shopify/erb-lint

## Post-deployment tasks

We are using [After Party](https://github.com/theSteveMitchell/after_party) to
run post-deployment tasks. These tasks may include one-time necessary updates to the
database. Run the tasks manually by:
```
bundle exec rake after_party:run
```

Alternatively, every time you pull the main branch, run:
```
bin/setup
```

which will update gems, run any database migrations, and run the after party
post-deployment tasks.

## Testing Suite

We are using [RSpec](http://rspec.info/) for tests. Before beginning a new
feature, please run the specs and make sure the entire test suite is passing.
All tests should be passing when submitting a PR. Please write specs as
appropriate.

To run all specs:

```
bundle exec rspec spec -fd
```

To run an individual file:

```
bundle exec rspec spec/models/user_spec.rb -fd
```

To run an individual spec, pass the spec name or partial match:
```
bundle exec rspec spec/models/user_spec.rb -fd -e "valid factory"
```

Individual specs can also be run by specifying the line number:

```
bundle exec rspec spec/models/user_spec.rb:4 -fd
```

The `-fd` flag is for "format: documentation", and will list out each spec name
as it is run. These flags can be left off for more concise output.

### JavaScript system specs

For system specs that require JavaScript, append `js: true` to the relevant
scenario, context, or describe statement. This has the added benefit of
generating a screenshot upon failure. To force any non-JS-requiring system test
to generate a screenshot, you can also temporarily add `js: true` to the spec to
help diagnose the failure. For example:

```
# spec/system/standards_import/new_spec.html.erb

it "shows success message", js: true do
 ...
end
```

By default we are using the headless version of Chrome to run system specs with
JavaScript, but you can run the non-headless version to watch the spec get run
in the browser. To use the non-headless version, add `debug: true` to the spec:

```
# spec/system/standards_import/new_spec.html.erb

it "shows success message", debug: true do
 ...
end
```

Any errors when running in debug mode will also create a screenshot in the `tmp`
directory to help with debugging.

### Deployment

Every time `main` is updated, it will trigger a deploy to Heroku automatically.

### Feature Flags

We use Flipper for our feature flags system.

You can turn on a feature flag by running:

`Flipper.enable(:search)`

and check if it's enabled with:

`Flipper.enabled?(:search) # true`
