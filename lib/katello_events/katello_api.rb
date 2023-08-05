require 'json'
require 'net/http'
require 'uri'
require 'katello_events/version'

module KatelloEvents
  class KatelloApi

    class Error < StandardError; end;

    def initialize(uri)
      @uri = URI.join(ENV['KATELLO_URI'], uri)
      @http = Net::HTTP.new(@uri.hostname, @uri.port,)
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_PEER
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

    def self.handle_candlepin_event
      @handle_candlepin_event ||= new('/api/internal/candlepin_events/handle')
    end

    def self.candlepin_events_heartbeat
      @candlepin_events_heartbeat ||= new('/api/internal/candlepin_events/heartbeat')
    end

    def post
      request = Net::HTTP::Post.new(@uri)
      request.add_field('Accept', 'application/json')
      request['User-Agent'] = "katello_events/#{KatelloEvents::VERSION}"
      request.content_type = 'application/json'
      request.body = JSON.dump(yield) if block_given?

      begin
        response = @http.request(request)
      rescue Errno::ECONNREFUSED
        raise Error.new("Katello was offline")
      end

      case response
      when Net::HTTPSuccess
        response
      else
        raise Error.new("Request error #{response.code}")
      end
    end

    def start
      @http.start do
        yield(self)
      end
    rescue Errno::ECONNREFUSED
      raise Error.new("Katello is offline")
    end

  end
end
