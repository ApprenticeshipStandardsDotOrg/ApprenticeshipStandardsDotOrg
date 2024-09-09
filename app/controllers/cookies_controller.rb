class CookiesController < ApplicationController
  def create
    session[:cookies_accepted] = params[:cookies] if params[:cookies]
    redirect_to request.referrer, format: :html
  end
end
