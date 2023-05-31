class Users::InvitationsController < Devise::InvitationsController
  # You can invite users via /users/invitation/new, but we don't want to allow that
  def new
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end
end
