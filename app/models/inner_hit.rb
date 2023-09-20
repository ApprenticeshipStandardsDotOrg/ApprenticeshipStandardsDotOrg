class InnerHit
  attr_reader :id, :title

  def self.from_result(inner_hits)
    inner_hits.map do |hit|
      InnerHit.new(
        id: hit["_id"],
        title: hit["_source"]["title"]
      )
    end
  end

  def initialize(id:, title:)
    @id = id
    @title = title
  end
end
