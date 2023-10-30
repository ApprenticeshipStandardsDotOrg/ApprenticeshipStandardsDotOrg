namespace :after_party do
  desc "Deployment task: cleanup_onet_codes"
  task cleanup_onet_codes: :environment do
    puts "Running deploy task 'cleanup_onet_codes'"

    occupation_standards = OccupationStandard.joins("LEFT JOIN onets ON (occupation_standards.onet_code = onets.code) WHERE onets.id IS NULL")

    occupation_standards.each do |occupation_standard|
      stripped_onet = occupation_standard.clean_onet_code
      onet = Onet.find_by(code: stripped_onet)
      occupation_standard.update(onet_code: stripped_onet, onet: onet)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
