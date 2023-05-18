namespace :after_party do
  desc "Deployment task: populate_industries"
  task populate_industries: :environment do
    puts "Running deploy task 'populate_industries'"

    industries = [
      ["11", "Management Occupations"],
      ["13", "Business and Financial Operations Occupations"],
      ["15", "Computer and Mathematical Occupations"],
      ["17", "Architecture and Engineering Occupations"],
      ["19", "Life, Physical, and Social Science Occupations"],
      ["21", "Community and Social Service Occupations"],
      ["23", "Legal Occupations"],
      ["25", "Educational Instruction and Library Occupations"],
      ["27", "Arts, Design, Entertainment, Sports, and Media Occupations"],
      ["29", "Healthcare Practitioners and Technical Occupations"],
      ["31", "Healthcare Support Occupations"],
      ["33", "Protective Service Occupations"],
      ["35", "Food Preparation and Serving Related Occupations"],
      ["37", "Building and Grounds Cleaning and Maintenance Occupations"],
      ["39", "Personal Care and Service Occupations"],
      ["41", "Sales and Related Occupations"],
      ["43", "Office and Administrative Support Occupations"],
      ["45", "Farming, Fishing, and Forestry Occupations"],
      ["47", "Construction and Extraction Occupations"],
      ["49", "Installation, Maintenance, and Repair Occupations"],
      ["51", "Production Occupations"],
      ["53", "Transportation and Material Moving Occupations"],
      ["55", "Military Specific Occupations"]
    ]

    industries.each do |prefix, name|
      Rails.error.handle(context: {prefix: prefix, name: name}) do
        Industry.create_with(name: name).find_or_create_by!(prefix: prefix, version: "2018")
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
