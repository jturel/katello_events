# frozen_string_literal: true

require 'stomp'
require 'katello_events/received_message'

module KatelloEvents
  class StompConnection
    # rubocop:disable Metrics/MethodLength
    def initialize(settings:, logger:)
      ssl_params = Stomp::SSLParams.new(
        key_file: settings[:ssl_key_file],
        cert_file: settings[:ssl_cert_file],
        ts_files: settings[:ssl_ca_file],
        fsck: false
      )

      @logger = logger

      @config = {
        hosts: [
          {
            host: settings[:broker_host],
            port: settings[:broker_port],
            ssl: ssl_params
          }
        ],
        logger: @logger,
        max_reconnect_attempts: 0,
        start_timeout: 2,
        reliable: false,
        connect_headers: {
          'accept-version': '1.2',
          'host': settings[:broker_host],
          'heart-beat': '30000,30000',
          'client-id': settings[:client_id]
        }
      }

      @queue_name = settings[:queue_name]
      @subscription_name = settings[:subscription_name]
      @client = nil
    end
    # rubocop:enable Metrics/MethodLength

    def subscribe(queue_name: @queue_name, subscription_name: @subscription_name)
      options = {}
      options['ack'] = 'client-individual'
      options['durable-subscription-name'] = subscription_name if subscription_name

      client.subscribe(queue_name, options) do |message|
        received_message = KatelloEvents::ReceivedMessage.new(body: message.body, headers: message.headers)
        yield(received_message)
        client.ack(message)
      end

      @logger.info("Subscribed to #{queue_name}.#{subscription_name}")
    end

    def running?
      @client&.running && @client&.open?
    end

    def open?
      @client&.open?
    end

    def close
      return unless open?

      @client.close
    end

    private

    def client
      @client ||= ::Stomp::Client.new(@config)
    end
  end
end
