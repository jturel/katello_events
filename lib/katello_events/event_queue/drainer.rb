# frozen_string_literal: true

require 'katello_events/katello_api'

module KatelloEvents
  module EventQueue
    class Drainer
      def initialize(logger:)
        @logger = logger
        @stop = false
        @reset = false
      end

      def reset
        return if @reset # there shouldn't be a reason to invoke this more than once per invocation of the service

        ::KatelloEvents::KatelloApi.event_queue_reset.post
        @reset = true
      end

      def drain
        @processed = 0
        start = Time.now

        ::KatelloEvents::KatelloApi.event_queue_next.start do |api|
          drain_loop(api)
        end
        #drain_loop(nil)
      ensure
        @logger.info("event queue processed=#{@processed} elapsed=#{Time.now-start}") unless @processed.zero?
      end

      def stop
        @stop = true
      end

      private

      def drain_loop(api)
        return if @stop

        #response = ::KatelloEvents::KatelloApi.event_queue_next.post
        response = api.post
        return unless response.code == '200'

        @processed += 1
        drain_loop(api)
      end
    end
  end
end
