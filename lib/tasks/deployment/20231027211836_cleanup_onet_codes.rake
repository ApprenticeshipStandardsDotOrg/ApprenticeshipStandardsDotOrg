namespace :after_party do
  desc "Deployment task: cleanup_onet_codes"
  task cleanup_onet_codes: :environment do
    puts "Running deploy task 'cleanup_onet_codes'"

    occupation_standards = OccupationStandard.joins("LEFT JOIN onets ON (occupation_standards.onet_code = onets.code) WHERE onets.id IS NULL")
    # correct format 12-3456.07

    occupation_standards.each do |occupation_standard|
      if occupation_standard.onet_code.present? && !occupation_standard.onet_code == "onet"
        stripped_onet = occupation_standard.onet_code.gsub!(/[^0-9A-Za-z]/, "")
        stripped_onet.insert(2, "-").insert(7, ".")
        onet = Onet.find_by(code: stripped_onet)
        occupation_standard.update(onet_code: stripped_onet, onet: onet)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
