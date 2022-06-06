module HashLogging
  include ActiveSupport::TaggedLogging

  def self.new(logger)
    logger.formatter ||= ActiveSupport::Logger::SimpleFormatter.new
    logger.formatter.extend Formatter
    logger.extend(self)
  end

  module Formatter
    include ActiveSupport::TaggedLogging::Formatter

    def call(severity, timestamp, progname, msg)
      tagged_message = if msg.is_a?(Hash)
                         tags_text.present? ? msg.merge(tags: tags_text) : msg
                       elsif tags_text.present?
                         { message: msg, tag: tags_text }
                       else
                         msg
                       end

      self.class.instance_method(:call).bind(self).call(severity,
                                                        timestamp,
                                                        progname,
                                                        tagged_message)
    end
  end
end