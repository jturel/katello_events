require 'katello_events/katello_api'
require 'katello_events/candlepin/client_factory'
require 'katello_events/candlepin/handler'

module KatelloEvents
  module Candlepin
    class Listener
      def initialize(logger:)
        @logger = logger
        @client_factory = ClientFactory
        @client = nil
      end

      def reset_client
        @client&.close
        @client = nil
      end

      def start
        return if running?
        begin
          reset_client
          @client = @client_factory.get(@logger)
          @client.subscribe do |message|
            handler = Handler.new(message, @logger)
            handler.handle
          end
          @logger.info 'started candlepin event listener'
        rescue Errno::ECONNREFUSED => e
          @logger.error e
          reset_client
        end
      end

      def running?
        @client&.running? || false
      end

      def stop
        reset_client
        @logger.info "stopped candlepin event listener"
      end

      def heartbeat
        KatelloApi.candlepin_events_heartbeat.post do
          {
            running: running?
          }
        end
      end
    end
  end
end
