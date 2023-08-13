# frozen_string_literal: true

require 'katello_events/event_queue/drainer'
require 'katello_events/katello_api'

module KatelloEvents
  module EventQueue
    class Poller
      def initialize(logger:, drainer:)
        @logger = logger
        @drainer = drainer
        @db_username = 'katello'
        @db_password = 'katello'
        @db_host = 'localhost'
        @db_name = 'katello'
      end

      def connect_database
        require 'pg'

        @connection ||= PG::Connection.new(
          host: @db_host,
          dbname: @db_name,
          user: @db_username,
          password: @db_password
        )
      end

      def runnable_events?
        query = event_count_query.gsub('TIME_PLACEHOLDER', Time.now.utc.to_s)

        @connection.exec(query) do |result|
          return result.values.first.first.to_i.positive?
        end
      end

      def event_count_query
        @query ||= begin
                    response =  KatelloApi.event_queue_query.get
                    query = JSON.parse(response.body)['query']
                    @logger.info query
                    query
                  end
      end

      def tick
        connect_database
        @drainer.reset
        #response = KatelloApi.event_queue_subscribe.get
        #@drainer.drain if response.code == '200'
        @drainer.drain if runnable_events?
      rescue KatelloApi::Error => e
        @logger.error "Katello API error: #{e.message}"
      end

      def stop
        @drainer.stop
      end
    end
  end
end
