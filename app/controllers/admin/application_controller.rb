module Admin
  class ApplicationController < Administrate::ApplicationController
    include ActiveStorage::SetCurrent
    include Administrate::Punditize

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    before_action :authenticate_admin
    after_action :verify_authorized # Pundit

    def authenticate_admin
      authenticate_user!
    end

    private

    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      redirect_back(fallback_location: root_path)
    end
  end
end
