class StateStandardsController < OccupationStandardsController
  private

  def standards_scope
    OccupationStandard
      .where(national_standard_type: nil)
      .includes(:organization, occupation: :onet)
  end
end
