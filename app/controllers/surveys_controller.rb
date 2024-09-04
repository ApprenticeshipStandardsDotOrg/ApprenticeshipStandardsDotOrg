class SurveysController < ApplicationController
  def create
  end

  def dismiss
    survey_modal_service = SurveyModalService.new(cookies)
    survey_modal_service.mark_as_dismissed!

    redirect_to request.referrer, format: :html
  end
end
