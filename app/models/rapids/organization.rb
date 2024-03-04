module RAPIDS
  class Organization
    def self.initialize_from_response(work_process_data)
      ::Organization.new(
        title: work_process_data["sponsorName"]
      )
    end
  end
end
