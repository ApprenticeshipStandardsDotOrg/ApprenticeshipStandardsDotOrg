module Admin
  class ApplicationController < Administrate::ApplicationController
    include ActiveStorage::SetCurrent

    before_action :authenticate_admin

    def authenticate_admin
      authenticate_user!
    end
  end
end
