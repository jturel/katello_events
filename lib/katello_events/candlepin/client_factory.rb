# frozen_string_literal: true

require 'katello_events/stomp_connection'

module KatelloEvents
  module Candlepin
    class ClientFactory
      def self.get(logger)
        ::KatelloEvents::StompConnection.new(
          logger: logger,
          settings: {
            ssl_cert_file: ENV.fetch('SSL_CLIENT_CERT', nil),
            ssl_key_file: ENV.fetch('SSL_CLIENT_KEY', nil),
            ssl_ca_file: ENV.fetch('SSL_CA_FILE', nil),
            broker_host: ENV.fetch('BROKER_HOST', nil),
            broker_port: ENV.fetch('BROKER_PORT', nil),
            queue_name: ENV.fetch('QUEUE_NAME', nil),
            subscription_name: ENV.fetch('SUBSCRIPTION_NAME', nil),
            client_id: ENV.fetch('CLIENT_ID', nil)
          }
        )
      end
    end
  end
end
