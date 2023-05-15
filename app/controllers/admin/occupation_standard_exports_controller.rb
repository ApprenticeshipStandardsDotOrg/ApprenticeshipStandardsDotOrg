module Admin
  class OccupationStandardExportsController < Admin::ApplicationController
    def show
      occupation_standard = OccupationStandard.find(params[:id])
      authorize_resource(occupation_standard)

      render json: {"ok": "ok"}
    end
  end
end
