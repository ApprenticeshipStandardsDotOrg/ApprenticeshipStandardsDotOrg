module Admin
  class ApplicationController < Administrate::ApplicationController
    include ActiveStorage::SetCurrent
    include Administrate::Punditize

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    before_action :authenticate_admin
    after_action :verify_authorized # Pundit

    def authenticate_admin
      authenticate_user!

      return if current_user.admin? || current_user.converter?

      sign_out current_user
      redirect_to new_user_session_path, alert: "You are not authorized to access the admin area."
    end

    private

    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      redirect_back(fallback_location: root_path)
    end

    def default_sorting_attribute
      :created_at
    end

    def default_sorting_direction
      :desc
    end
  end
end
