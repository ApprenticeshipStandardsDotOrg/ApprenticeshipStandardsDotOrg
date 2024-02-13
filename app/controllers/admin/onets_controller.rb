module Admin
  class OnetsController < Admin::ApplicationController
    private

    def default_sorting_attribute
      :code
    end

    def default_sorting_direction
      :asc
    end
  end
end
