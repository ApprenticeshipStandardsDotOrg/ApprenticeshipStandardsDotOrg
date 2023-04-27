class ApplicationController < ActionController::Base
  include ActiveStorage::SetCurrent
  include Pagy::Backend
end
