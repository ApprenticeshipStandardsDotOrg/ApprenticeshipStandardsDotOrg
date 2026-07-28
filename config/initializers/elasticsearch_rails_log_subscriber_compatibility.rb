if defined?(Elasticsearch::Rails::Instrumentation::LogSubscriber)
  module ElasticsearchRailsLogSubscriberCompatibility
    def search(event)
      self.class.runtime += event.duration
      return unless logger.debug?

      payload = event.payload
      name = "#{payload[:klass]} #{payload[:name]} (#{event.duration.round(1)}ms)"
      search = payload[:search].inspect.gsub(/:(\w+)=>/, '\1: ')

      debug "  #{color(name, self.class::GREEN, bold: true)} #{colorize_logging ? "\e[2m#{search}\e[0m" : search}"
    end
  end

  Elasticsearch::Rails::Instrumentation::LogSubscriber.prepend(
    ElasticsearchRailsLogSubscriberCompatibility
  )
end
