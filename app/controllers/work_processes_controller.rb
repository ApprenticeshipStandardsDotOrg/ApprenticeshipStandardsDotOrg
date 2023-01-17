class WorkProcessesController < ApplicationController
  before_action :authenticate_user!

  def index
    @work_processes = WorkProcess.includes
  end

  def new
    @work_process = WorkProcess.new
  end

  def create
    @work_process = WorkProcess.new(create_params)

    if @work_process.save
      redirect_to work_processes
    else
      render :new
    end
  end

  private

  def create_params
    params.require(:work_process).permit(:title, :description, :occupation_standard_id, 
      :default_hours, :minimum_hours, :maximum_hours, :sort_order)
  end
end
