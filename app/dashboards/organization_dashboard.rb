require "administrate/base_dashboard"

class OrganizationDashboard < Administrate::BaseDashboard
  def display_resource(organization)
    organization.title
  end
end
