class PopularOnetCodesQuery
  def self.run(limit: 4)
    OccupationStandard.where.not(onet_code: nil)
      .group(:onet_code)
      .order("COUNT(onet_code) DESC").limit(limit)
  end
end
