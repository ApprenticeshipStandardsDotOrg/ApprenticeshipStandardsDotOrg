class PopularOnetCodesQuery
  LIMIT = 4
  def self.run(limit: LIMIT)
    OccupationStandard
      .joins(:work_processes)
      .where.not(onet_code: nil)
      .group(:onet_code)
      .order(Arel.sql("COUNT(DISTINCT occupation_standards.id) DESC"))
      .limit(limit)
      .pluck(:onet_code)
  end
end
