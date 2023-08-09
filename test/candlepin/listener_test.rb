# frozen_string_literal: true

require_relative '../test_helper'
require 'katello_events/candlepin/listener'

module KatelloEvents
  module Candlepin
    class ListenerTest < ::Minitest::Test
      def setup
        @listener = KatelloEvents::Candlepin::Listener.new(
          logger: TEST_LOGGER
        )
      end

      def test_start
        mock_stomp = stub(:stomp_connection, subscribe: true)
        KatelloEvents::StompConnection.expects(:new).returns mock_stomp
        assert @listener.start
      end

      def test_heartbeat; end
    end
  end
end
