class SurveysController < ApplicationController
  def create
    survey = Survey.new(survey_params)
    if survey.save
      survey_modal_service = SurveyModalService.new(cookies)
      survey_modal_service.mark_as_submitted!
    end

    redirect_to request.referrer, format: :html
  end

  def dismiss
    survey_modal_service = SurveyModalService.new(cookies)
    survey_modal_service.mark_as_dismissed!

    redirect_to request.referrer, format: :html
  end

  private

  def survey_params
    params.require(:survey).permit(:name, :email, :organization)
  end
end
