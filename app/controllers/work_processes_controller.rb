class WorkProcessesController < ApplicationController
  before_action :authenticate_user!

  def index
    @work_processes = WorkProcess.includes
  end

  def new
    @work_process = WorkProcess.new
  end
end
