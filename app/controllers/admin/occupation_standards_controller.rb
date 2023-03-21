class Admin::OccupationStandardsController < Admin::BaseController
  before_action :find_occupation_standard, only: [:show, :edit, :update]

  def index
    @occupation_standards = OccupationStandard.includes(occupation: :onet, registration_agency: :state)
  end

  def show
  end

  def edit
  end

  def update
    if @occupation_standard.update(update_params)
      redirect_to [:admin, @occupation_standard]
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def find_occupation_standard
    @occupation_standard = OccupationStandard.find(params[:id])
  end

  def update_params
    params.require(:occupation_standard).permit(:title, :onet_code, :rapids_code, :status)
  end
end
