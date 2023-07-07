class ContactRequestsController < ApplicationController
  before_action :verify_recaptcha, only: :create

  VALID_RECAPTCHA_SCORE = 0.5

  def new
    @contact_request = ContactRequest.new
  end

  def create
    @contact_request = ContactRequest.new(contact_request_params)

    if @contact_request.save
      flash[:notice] = "Thank you for contacting us! We've received your note and will reply to you soon!"
      redirect_to guest_root_path
    else
      render :new, status: :unprocessable_entity
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

  def verify_recaptcha
    uri = URI("https://www.google.com/recaptcha/api/siteverify")
    resp = Net::HTTP.post_form(
      uri,
      secret: ENV["GOOGLE_RECAPTCHA_SECRET_KEY"],
      response: params["g-recaptcha-response"],
      remoteip: request.remote_ip
    )
    parsed_json = JSON.parse(resp.body)
    success = parsed_json["success"]
    score = parsed_json["score"].to_f

    unless success
      Rails.error.report("Error with Google reCAPTCHA", context: parsed_json, handled: true)
    end

    if !success || score < VALID_RECAPTCHA_SCORE
      redirect_to guest_root_path
    end
  end
end
