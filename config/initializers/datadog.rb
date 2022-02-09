if defined?(Datadog) && ENV['DATADOG_HOST']
  Datadog.configure do |c|
    # This will activate auto-instrumentation for Rails
    c.use :rails
    c.tracer hostname: ENV['DATADOG_HOST'], port: ENV['DATADOG_PORT']
  end

  Rails.application.configure do
    # Lograge config
    config.lograge.enabled = true

    # This specifies to log in JSON format
    config.lograge.formatter = Lograge::Formatters::Json.new

    ## Disables log coloration
    config.colorize_logging = false

    # Log to a dedicated file
    # config.lograge.logger = ActiveSupport::Logger.new(
    #   File.join(Rails.root, 'log', "#{Rails.env}.log")
    # )

    # This is useful if you want to log query parameters
    config.lograge.custom_options = lambda do |event|
      {
        ddsource: 'ruby',
        params: event.payload[:params].reject { |k| %w[controller action].include? k }
      }
    end
  end
end
