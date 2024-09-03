class SurveyModalService
  attr_reader :cookies

  COOKIE_NAME = "as_survey_modal"
  MININUM_AMOUNT_OF_VISITS = 2
  RECURRENCY_TIME_TABLE = {
    1 => 7.days,
    2 => 1.month,
    3 => 3.months
  }

  INITIAL_COOKIE_INFO = {
    submitted: false,
    standardsVisitedCount: 1,
    dismissed: false
  }

  def initialize(cookies)
    @cookies = cookies
  end

  def show?
    return false unless cookie_present?

    minimum_amount_of_visits_reached? &&
      !submitted?
  end

  def upsert_cookie!
    if cookie_present?
      update_cookie!
    else
      create_cookie!
    end
  end

  private

  def cookie_present?
    cookies.encrypted[COOKIE_NAME].present?
  end

  def minimum_amount_of_visits_reached?
    parsed_cookies["standardsVisitedCount"] >= MININUM_AMOUNT_OF_VISITS
  end

  def submitted?
    parsed_cookies["submitted"] == true
  end

  def create_cookie!
    @cookies.encrypted[COOKIE_NAME] = JSON.generate(INITIAL_COOKIE_INFO)
  end

  def update_cookie!
    values = parsed_cookies
    values["standardsVisitedCount"] += 1

    @cookies.encrypted[COOKIE_NAME] = JSON.generate(values)
  end


  def parsed_cookies
    JSON.parse(
      cookies.encrypted[COOKIE_NAME]
    )
  end
end
