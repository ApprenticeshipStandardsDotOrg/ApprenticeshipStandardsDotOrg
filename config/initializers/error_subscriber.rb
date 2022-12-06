class ErrorSubscriber
  def report(error, handled:, severity:, context:, source: nil)
    if Rails.env.development?
      raise error
    end
  end
end
