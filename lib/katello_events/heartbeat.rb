# frozen_string_literal: true

require 'katello_events/katello_api'

module KatelloEvents
  class Heartbeat
    def initialize(interval:, service:, logger:)
      @last_heartbeat = Time.now
      @interval = interval
      @service = service
      @logger = logger
    end

    def trigger
      return unless Time.now > @last_heartbeat + @interval

      begin
        @service.heartbeat
      rescue KatelloApi::Error
        @logger.error 'heartbeat error'
      end

      @last_heartbeat = Time.now
    end
  end
end
