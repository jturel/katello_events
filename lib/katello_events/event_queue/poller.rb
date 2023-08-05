require 'katello_events/event_queue/drainer'
require 'katello_events/katello_api'

module KatelloEvents
  module EventQueue
    class Poller
      attr_reader :last_tick

      def initialize(logger:, drainer:)
        @logger = logger
        @drainer = drainer
        @last_tick = Time.at(0)
        @tick_interval = 3
      end

      def heartbeat
        KatelloApi.event_queue_heartbeat.post do
          {
            last_tick: @last_tick
          }
        end
      end

      def tick
        return if Time.now < @last_tick + @tick_interval

        @drainer.reset
        @drainer.drain
        @last_tick = Time.now
      rescue KatelloApi::Error => e
        @logger.error "event queue error: #{e.message}"
      end

      def stop
        @drainer.stop
      end
    end
  end
end