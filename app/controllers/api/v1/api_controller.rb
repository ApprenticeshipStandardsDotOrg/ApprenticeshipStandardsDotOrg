class API::V1::APIController < ApplicationController
  include JSONAPI::ActsAsResourceController

  protect_from_forgery with: :null_session
end
