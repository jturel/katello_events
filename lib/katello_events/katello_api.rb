require 'json'
require 'net/http'
require 'uri'
require 'katello_events/version'

module KatelloEvents
  class KatelloApi

    class Error < StandardError; end;

    def initialize(uri, read_timeout = nil)
      @uri = URI.join(ENV['KATELLO_URI'], uri)
      @http = Net::HTTP.new(@uri.hostname, @uri.port)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      @http.max_retries = 0 # katello_events is about retrying requests - don't use the http lib to do it
      @http.read_timeout = read_timeout if read_timeout
      @http.cert = OpenSSL::X509::Certificate.new(File.read(ENV['SSL_CLIENT_CERT']))
      @http.key = OpenSSL::PKey::RSA.new(File.read(ENV['SSL_CLIENT_KEY']))
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
        raise Error.new("Request error #{response.code}")
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
