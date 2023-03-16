module Admin
  class OccupationStandardsController < Admin::ApplicationController
    def scoped_resource
      OccupationStandard.includes(occupation: :onet_code, registration_agency: :state)
    end
  end
end
