if defined?(Datadog)
  Datadog.configure do |c|
    # This will activate auto-instrumentation for Rails
    c.use :rails
    c.tracer hostname: ENV['DATADOG_HOST'], port: ENV['DATADOG_PORT']
  end
end
