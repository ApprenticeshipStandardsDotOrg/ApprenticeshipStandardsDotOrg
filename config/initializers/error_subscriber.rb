class ErrorSubscriber
  def report(error, handled:, severity:, context:, source: nil)
    if Rails.env.development?
      raise error
    elsif Rails.env.production?
      Rollbar.send(severity, error, context)
    end
  end
end
