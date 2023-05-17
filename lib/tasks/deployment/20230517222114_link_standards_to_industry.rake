namespace :after_party do
  desc "Deployment task: link_standards_to_industry"
  task link_standards_to_industry: :environment do
    puts "Running deploy task 'link_standards_to_industry'"

    OccupationStandard.where("onet_code IS NOT NULL AND onet_code != ''").find_each do |standard|
      if (matches = standard.onet_code.match(/\A(?<prefix>\d{2})/))
        Rails.error.handle(context: {standard_id: standard.id}) do
          industry = Industry.where(prefix: matches[:prefix], version: Industry::CURRENT_VERSION).sole
          standard.update_columns(industry_id: industry.id)
        end
      else
        Rails.error.report("Missing industry for standard", context: {standard_id: standard.id, onet_code: standard.onet_code}, handled: false)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
