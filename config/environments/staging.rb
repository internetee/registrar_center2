require_relative "production"

Rails.application.configure do
  # Staging inherits production (Redis cache, SSL, assets, etc.).
  # Override only what differs per environment.

  require "syslog/logger"
  config.logger = ActiveSupport::TaggedLogging.new(
    Syslog::Logger.new(ENV.fetch("SYSLOG_APP_NAME", "newrar-staging"))
  )

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end
end
