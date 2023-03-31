require "administrate/base_dashboard"

class RegistrationAgencyDashboard < Administrate::BaseDashboard
  def display_resource(registration_agency)
    registration_agency.to_s
  end
end
