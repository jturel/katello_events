require 'katello_events/stomp_connection'

module KatelloEvents
  module Candlepin
    class ClientFactory

      def self.get(logger)
        ::KatelloEvents::StompConnection.new(
          logger: logger,
          settings: {
            ssl_cert_file: ENV['SSL_CLIENT_CERT'],
            ssl_key_file: ENV['SSL_CLIENT_KEY'],
            ssl_ca_file: ENV['SSL_CA_FILE'],
            broker_host: ENV['BROKER_HOST'],
            broker_port: ENV['BROKER_PORT'],
            queue_name: ENV['QUEUE_NAME'],
            subscription_name: ENV['SUBSCRIPTION_NAME'],
            client_id: ENV['CLIENT_ID']
          }
        )
      end
    end
  end
end
