module RAPIDS
  class Competency
    def self.initialize_from_response(competency_data)
      ::Competency.new(
        title: competency_data["title"],
        sort_order: competency_data["sort_order"]
      )
    end
  end
end
