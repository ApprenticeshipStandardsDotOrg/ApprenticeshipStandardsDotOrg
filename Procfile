web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 3 -q default
aiworker: ruby bin/ai-worker
release: bundle exec rails db:migrate && rake after_party:run
