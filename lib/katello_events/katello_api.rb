# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'
require 'katello_events/version'

module KatelloEvents
  class KatelloApi
    class Error < StandardError; end

    def initialize(path, read_timeout = 60)
      #@uri = URI.join(ENV.fetch('KATELLO_URI', nil), uri)
      @uri = URI::HTTPS.build(host: ENV['KATELLO_URI'], path: path)
      @http = Net::HTTP.new(@uri.hostname, @uri.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      @http.max_retries = 0 # this could lead to things like multiple event queue subscriptions; don't enable this
      @http.read_timeout = read_timeout
      @http.cert = self.class.ssl_cert
      @http.key = self.class.ssl_key
    end

    def self.ssl_cert
      @ssl_cert ||= OpenSSL::X509::Certificate.new(File.read(ENV.fetch('SSL_CLIENT_CERT', nil)))
    end

    def self.ssl_key
      @ssl_key ||= OpenSSL::PKey::RSA.new(File.read(ENV.fetch('SSL_CLIENT_KEY', nil)))
    end

    def self.event_queue_heartbeat
      @event_queue_heartbeat ||= new('/api/internal/event_queue/heartbeat')
    end

    def self.event_queue_next
      @event_queue_next ||= new('/api/internal/event_queue/next')
    end

    def self.event_queue_reset
      @event_queue_reset ||= new('/api/internal/event_queue/reset')
    end

    def self.event_queue_subscribe
      # The timeout specified here should be slightly larger than the subscription timeout on the server side
      @event_queue_subscribe ||= new('/api/internal/event_queue/subscribe', 180)
    end

    def self.event_queue_query
      @event_queue_query ||= new('/api/internal/event_queue/query')
    end

    def self.handle_candlepin_event
      @handle_candlepin_event ||= new('/api/internal/candlepin_events/handle')
    end

    def self.candlepin_events_heartbeat
      @candlepin_events_heartbeat ||= new('/api/internal/candlepin_events/heartbeat')
    end

    def get
      request = Net::HTTP::Get.new(@uri)
      request.add_field('Accept', 'application/json')
      request['User-Agent'] = "katello_events/#{KatelloEvents::VERSION}"

      safe_request do
        @http.request(request)
      end
    end

    def post
      request = Net::HTTP::Post.new(@uri)
      request.add_field('Accept', 'application/json')
      request['User-Agent'] = "katello_events/#{KatelloEvents::VERSION}"
      request.content_type = 'application/json'
      request.body = JSON.dump(yield) if block_given?

      response = safe_request do
        @http.request(request)
      end

      case response
      when Net::HTTPSuccess
        response
      else
        raise Error, "Request error #{response.code}"
      end
    end

    def start
      safe_request do
        @http.start do
          yield(self)
        end
      end
    end

    private

    def safe_request
      yield
    rescue Errno::ECONNREFUSED
      raise Error, 'Server offline'
    rescue Net::ReadTimeout
      raise Error, 'Request timed out'
    end
  end
end
