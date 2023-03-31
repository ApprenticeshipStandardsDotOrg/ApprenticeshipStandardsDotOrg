require "administrate/base_dashboard"

class OccupationDashboard < Administrate::BaseDashboard
  def display_resource(occupation)
    occupation.to_s
  end
end
