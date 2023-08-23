class State < ApplicationRecord
  POPULAR_LIMIT = 4

  has_many :registration_agencies
  has_many :occupation_standards, through: :registration_agencies

  def self.popular(limit: POPULAR_LIMIT)
    State.joins(occupation_standards: :work_processes)
      .group("states.id")
      .order(Arel.sql("COUNT(DISTINCT occupation_standards.id) DESC"))
      .limit(limit)
  end

  def occupation_standards_count
    (occupation_standards.with_work_processes.count > 0) ? occupation_standards.with_work_processes.count : ""
  end
end
