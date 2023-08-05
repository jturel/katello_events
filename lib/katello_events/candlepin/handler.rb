module KatelloEvents
  module Candlepin
    class Handler
      EVENT_TARGET = 'EVENT_TARGET'.freeze
      EVENT_TYPE = 'EVENT_TYPE'.freeze

      def initialize(message, logger)
        @message = message
        @subject = "#{message.headers['EVENT_TARGET']}.#{message.headers[EVENT_TYPE]}".downcase
        @logger = logger
      end

      def handle
        ::KatelloEvents::KatelloApi.handle_candlepin_event.post do
          {
            content: @message.body,
            subject: @subject
          }
        end
        @logger.info "Handled #{@subject}"
      rescue KatelloApi::Error

      end
    end
  end
end
