# frozen_string_literal: true

require 'uri'
require 'net/http'

module Katello
  class EventQueueDrainer
    def initialize
      @uri = URI.join('https://centos8-katello-devel.fedora-t480.example.com', '/api/internal/event_queue/next')
      @request = Net::HTTP::Post.new(@uri)
      @request.add_field('Accept', 'application/json')
      @request.content_type = 'application/json'
      @http = Net::HTTP.new(@uri.hostname, @uri.port)
      @http.use_ssl = true
    end

    def drain
      loop do
        begin
          @http.start do |http|
            drain_loop(http)
          end
        rescue StandardError => e
          puts e
        end
        sleep 3
      end
    end

    private

    def drain_loop(http)
      response = http.request(@request)
      drain_loop(http) unless response.code == '204'
    end
  end
end

drainer = Katello::EventQueueDrainer.new
drainer.drain
