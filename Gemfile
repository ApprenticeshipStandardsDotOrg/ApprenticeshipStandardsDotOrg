source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "rails", "~> 7.1.3"

gem "elasticsearch", "8.10.0"
gem "elasticsearch-model", github: "elastic/elasticsearch-rails", branch: "8.x"
gem "elasticsearch-rails", github: "elastic/elasticsearch-rails", branch: "8.x"
gem "elasticsearch-dsl"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
gem "rubyzip"

# This is needed to make FoxitSDK work since it uses relative references to files without digest
gem "non-digest-assets", github: "mvz/non-digest-assets", branch: "master"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.5"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.4"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

gem "blueprinter"
gem "devise"
gem "devise_invitable", "~> 2.0.9"
gem "rollbar"
gem "roo", "~> 2.10.1"
gem "aws-sdk-s3", require: false
gem "after_party"
gem "sidekiq", "~> 7"
gem "watir", "~> 7.3"
gem "docx"
gem "administrate"
gem "administrate-field-active_storage"
gem "administrate-field-jsonb"
gem "pundit"
gem "image_processing"
gem "pagy"
gem "ruby-openai"
gem "pdf-reader"
gem "oauth2", "~> 2.0", ">= 2.0.9"

# Throttle excessive requests
gem "rack-attack"
gem "redis"

# This is needed  to make FoxitSDK work since it uses file paths relative to the view instead of /assests
gem "rack-rewrite", "~> 1.5.0"

# For API
gem "jsonapi-resources"
gem "jwt"

# For Swagger API documentation (non-public)
gem "rswag-api"
gem "rswag-ui"
gem "rack-cors"

gem "flipper"
gem "flipper-active_record"

gem "sablon" # Word document templating tool

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "bullet"
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "rspec-rails"
  gem "rswag-specs"
end

group :development do
  gem "erb_lint", require: false
  gem "erblint-github"
  gem "standard", "~> 1.35", ">= 1.35.1"
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"
end

group :test do
  gem "capybara"
  gem "capybara_accessible_selectors", git: "https://github.com/citizensadvice/capybara_accessible_selectors", tag: "v0.12.0"
  gem "selenium-webdriver"
  gem "webmock"
end
