require 'katello_events/event_queue/drainer'
require 'katello_events/katello_api'

module KatelloEvents
  module EventQueue
    class Poller
      def initialize(logger:, drainer:)
        @logger = logger
        @drainer = drainer
      end

      def tick
        @drainer.reset
        response = KatelloApi.event_queue_subscribe.get

        if response.code == '200'
          @drainer.drain
        end
      rescue KatelloApi::Error => e
        @logger.error "Katello API error: #{e.message}"
      end

      def stop
        @drainer.stop
      end
    end
  end
end
