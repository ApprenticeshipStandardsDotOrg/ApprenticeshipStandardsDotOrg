module RAPIDS
  class Competency
    def self.initialize_from_response(competency_data)
      ::Competency.new(
        title: competency_data["title"]
      )
    end
  end
end
