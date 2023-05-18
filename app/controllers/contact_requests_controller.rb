class ContactRequestsController < ApplicationController
  def new
    @contact_request = ContactRequest.new
  end

  def create
    @contact_request = ContactRequest.new(contact_request_params)

    if @contact_request.save
      flash[:notice] = "Thank you for contacting us! We've received your note and will reply to you soon!"
      redirect_to guest_root_path
    else
      render :new
    end
  end

  private

  def contact_request_params
    params.require(:contact_request).permit(
      :name,
      :organization,
      :email,
      :message
    )
  end
end
