module Admin
  class OrganizationsController < Admin::ApplicationController
    private

    def default_sorting_attribute
      :title
    end

    def default_sorting_direction
      :asc
    end
  end
end
