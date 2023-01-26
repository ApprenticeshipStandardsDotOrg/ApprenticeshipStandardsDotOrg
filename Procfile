web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 8
release: bundle exec rails db:migrate && rake after_party:run
