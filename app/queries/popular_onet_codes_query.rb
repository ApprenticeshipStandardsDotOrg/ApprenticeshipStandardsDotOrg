class PopularOnetCodesQuery
  LIMIT = 4
  def self.run(limit: LIMIT)
    OccupationStandard.where.not(onet_code: nil)
      .group(:onet_code)
      .order("COUNT(onet_code) DESC")
      .limit(limit)
      .pluck(:onet_code)
  end
end
