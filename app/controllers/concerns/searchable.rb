module Searchable
  extend ActiveSupport::Concern

  private

  def search_term_params
    {
      q: params[:q]
    }
  end
end
