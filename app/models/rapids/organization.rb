module RAPIDS
  class Organization
    def self.initialize_from_response(occupation_standard_data)
      ::Organization.new(
        title: occupation_standard_data["sponsorName"],
        sponsor_number: occupation_standard_data["sponsorNumber"]
      )
    end
  end
end
