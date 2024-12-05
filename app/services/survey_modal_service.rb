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
    dismissedCount: 0,
    dismissedAt: nil
  }

  def initialize(cookies)
    @cookies = cookies
  end

  def show?
    return false unless cookie_present?

    minimum_amount_of_visits_reached? &&
      !dismissed? &&
      !submitted?
  end

  def upsert_cookie!
    if cookie_present?
      update_cookie!
    else
      create_cookie!
    end
  end

  def mark_as_dismissed!
    values = parsed_cookies
    values["standardsVisitedCount"] += 1
    values["dismissedCount"] += 1
    values["dismissedAt"] = Time.current

    @cookies.encrypted[COOKIE_NAME] = JSON.generate(values)
  end

  def mark_as_submitted!
    values = parsed_cookies
    values["submitted"] = true

    @cookies.encrypted[COOKIE_NAME] = JSON.generate(values)
  end

  private

  def cookie_present?
    cookies.encrypted[COOKIE_NAME].present?
  end

  def minimum_amount_of_visits_reached?
    parsed_cookies["standardsVisitedCount"] >= MININUM_AMOUNT_OF_VISITS
  end

  def dismissed?
    dismissed_count = parsed_cookies["dismissedCount"]
    dismissed_at = parsed_cookies["dismissedAt"]

    return false if dismissed_count == 0 && dismissed_at.nil?

    recurrence_limit = RECURRENCY_TIME_TABLE.fetch(dismissed_count, 10.years)
    expiration_date = Time.new(dismissed_at) + recurrence_limit
    future = (Time.current..)

    future.cover?(expiration_date)
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
