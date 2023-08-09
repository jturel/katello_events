# frozen_string_literal: true

require_relative '../test_helper'
require 'katello_events/event_queue/poller'
require 'katello_events/event_queue/drainer'

module KatelloEvents
  module EventQueue
    class PollerTest < ::Minitest::Test
      def setup
        @drainer = Drainer.new(logger: TEST_LOGGER)
        @poller = Poller.new(logger: TEST_LOGGER, drainer: @drainer)
      end

      def test_tick
        @drainer.expects(:reset).once
        @drainer.expects(:drain).once
        2.times { @poller.tick }
      end

      def test_stop
        @drainer.expects(:stop)
        @poller.stop
      end

      def test_heartbeat
        heartbeat = stub_katello_request('/api/internal/event_queue/heartbeat')
                    .with(body: { last_tick: Time.at(0).to_s })
                    .to_return(status: 200)

        @poller.heartbeat

        assert_requested heartbeat
      end
    end
  end
end
