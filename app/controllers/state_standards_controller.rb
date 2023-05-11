class StateStandardsController < OccupationStandardsController
  private

  def standards_scope
    OccupationStandard
      .where(national_standard_type: nil)
      .includes(:organization, :work_processes, registration_agency: :state, occupation: :onet)
  end
end
