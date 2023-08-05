require_relative '../test_helper.rb'
require 'katello_events/event_queue/drainer'

module KatelloEvents
  module EventQueue
    class DrainerTest < ::Minitest::Test
      def setup
        @drainer = KatelloEvents::EventQueue::Drainer.new(logger: TEST_LOGGER)
      end

      def test_drain
        # test 204 and 200 for a full cycle
        first_event = stub_katello_request('/api/internal/event_queue/next').to_return(status: 200)
        events_cleared = stub_katello_request('/api/internal/event_queue/next').to_return(status: 204)

        @drainer.drain

        assert_requested first_event
        assert_requested events_cleared
      end

      def test_reset_single_request
        reset = stub_katello_request('/api/internal/event_queue/reset').to_return(status: 200)

        @drainer.reset
        @drainer.reset # not a mistake, testing single http request

        assert_requested reset
      end

      # TBD
      def test_stop_drain
        @drainer.stop

        @drainer.drain
      end

      def test_katello_api_error
        forbidden = stub_katello_request('/api/internal/event_queue/next').to_return(status: 403)

        assert_raises KatelloApi::Error do
          @drainer.drain
        end

        assert_requested forbidden
      end
    end
  end
end
