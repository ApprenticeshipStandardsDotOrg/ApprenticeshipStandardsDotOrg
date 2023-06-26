class PopularOnetCodesQuery
  def self.run(limit: 4)
    sql = "SELECT COUNT(onet_code), onet_code
    FROM occupation_Standards
    WHERE onet_code IS NOT NULL
    GROUP BY onet_code
    ORDER BY COUNT(onet_code) DESC
    LIMIT #{limit}"

    OccupationStandard.find_by_sql(sql).pluck(:onet_code)
  end
end
