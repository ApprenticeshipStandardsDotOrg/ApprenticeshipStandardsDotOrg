# ApprenticeshipStandards.org
The ApprenticeshipStandards.org application is currently running on Ruby 3,
Rails 7, and PostgreSQL 14.

## Development setup
1. [Install Elasticsearch](#elasticsearch-setup)
2. Start `elasticsearch` in the terminal, as the setup command
   will run some tasks to create Elasticsearch indexes.
3. Copy `.env.sample` to `.env` and edit the `ONET_WEB_SERVICES_USERNAME` and
   `ONET_WEB_SERVICES_PASSWORD` variables so you can run the setup task without
   issue.
1. Run `bin/setup`. One of the After Party tasks takes several minutes to
   run. Once completed, it will not run on subsequent `bin/setup` calls.
2. Kill `elasticsearch` as it will get started with the `bin/dev`
   command below
3. Install [mailcatcher][mailcatcher] to preview emails. See the
   [troubleshooting](#mailcatcher-troubleshooting) section if you have
   installation issues.
4. To access the admin pages, you must modify your `/etc/hosts` file:
   ```
   # Added for ApprenticeshipStandards.org
   127.0.0.1 admin.example.localhost
   # End ApprenticeshipStandards.org additions
   ```
5. Start the rails app with `bin/dev`:
    * The public facing application will be available at http://localhost:3000
    * The admin pages will be available at http://admin.example.localhost:3000
    * Email previews will be available at http://localhost:1080

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

### Libreoffice


If you want to convert doc and docx documents to PDF, you can install install [libreoffice][libreoffice] with [brew][libreoffice_brew]:

```bash
brew install --cask libreoffice
```

[libreoffice]: https://www.libreoffice.org/
[libreoffice_brew]: https://formulae.brew.sh/cask/libreoffice#default

## Staging access
[Staging information](https://www.notion.so/Engineering-f05ed81462494b80946bf83df50cb400)

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

## Elasticsearch setup
We are currently using Elasticsearch version 8.10.3. See the [Elasticsearch
documentation][ES-documentation]
for installation options. To debug any queries, set `log: true` in
the `config/initializers/elasticsearch.rb` client setup.

For your local Elasticsearch setup, if you get errors like:

> The client is unable to verify that the server is Elasticsearch. Some
> functionality may not be compatible if the server is running an unsupported
> product.

then you will need to turn off the security features for your Elasticsearch
configuration. Edit the `config/elasticsearch.yml` file in your Elasticsearch
installation to turn all the `enabled` flags to `false`:

```yml
xpack.security.enabled: false

xpack.security.enrollment.enabled: false

xpack.security.http.ssl:
  enabled: false
  keystore.path: certs/http.p12

xpack.security.transport.ssl:
  enabled: false
  verification_mode: certificate
  keystore.path: certs/transport.p12
  truststore.path: certs/transport.p12
cluster.initial_master_nodes: ["My-MacBook-Pro.local"]

http.host: 0.0.0.0
```

If you are using a docker image of  Elasticsearch you can start it with `docker run -p 9200:9200 -m 1GB -e "discovery.type=single-node" -e "xpack.security.enabled=false" docker.elastic.co/elasticsearch/elasticsearch:8.10.3`. Make sure the number at the end matches the version number for the image.

[ES-documentation]: https://www.elastic.co/guide/en/elasticsearch/reference/8.10/install-elasticsearch.html

### Kibana setup
If you are working on any tasks related to Elasticsearch, then it may be helpful
to set up [Kibana][kibana].

To start Kibana, make sure that elasticsearch is already running, then run
`kibana` in the terminal. Kibana will be available at http://localhost:5601. To
access the dev tools, click the hamburger menu icon in the nav, and go to "Dev
Tools" under the Management section.

To see all of the records in the `occupation_standards` in the Kibana Dev Tools enter:

```
GET occupation_standards_development/_search
{
  "query": {
    "match_all": {}
  }
}
```
and click the green arrow button to run the query. You should see data returned
for all of the OccupationStandard records in your local database in the panel on
the right.

If you need to view the names of all your indices, under the Management section
go to "Stack Management". Then under the Data section, click "Index Management"
to see the list of all the available indices.

[kibana]: https://www.elastic.co/guide/en/kibana/current/install.html

## AWS setup
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
bundle exec erblint --lint-all --autocorrect
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

## Feature Flags

We use [Flipper](https://github.com/jnunemaker/flipper) for our feature flags
system.

You can turn on a feature flag by running:

`Flipper.enable(:search)`

and check if it's enabled with:

`Flipper.enabled?(:search) # true`

When writing specs, there is a helper method to use:
`stub_feature_flag(:my_feature_flag, <boolean value>)`.
