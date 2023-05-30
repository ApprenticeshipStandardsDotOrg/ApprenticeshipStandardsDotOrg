class SimilarOccupationStandards
  def self.similar_to(occupation_standard)
    new(occupation_standard).top_five
  end

  def initialize(occupation_standard)
    @occupation_standard = occupation_standard
  end

  def top_five
    OccupationStandard.search
  end
end
