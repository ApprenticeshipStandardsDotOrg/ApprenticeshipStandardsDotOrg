class CookiesController < ApplicationController
  def create
    session[:cookies_accepted] = params[:cookies] if params[:cookies]
    redirect_to (request.referrer || guest_root_path), format: :html
  end
end
