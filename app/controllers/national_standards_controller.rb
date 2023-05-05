class NationalStandardsController < OccupationStandardsController
  private

  def standards_scope
    OccupationStandard
      .where.not(national_standard_type: nil)
      .includes(:organization, registration_agency: :state, occupation: :onet)
  end
end
