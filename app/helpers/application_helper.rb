module ApplicationHelper
  include Pagy::Frontend

  def search_form_url
    target = (controller_name == "pages") ? "occupation_standards" : controller_name
    url_for(controller: target, action: "index")
  end
end
