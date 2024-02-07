# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

# https://github.com/rswag/rswag/issues/359#issuecomment-728836401
if defined? RSpec
  RSpec.configure do |config|
    config.rswag_dry_run = false
  end
end

Rails.application.load_tasks
