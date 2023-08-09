# frozen_string_literal: true

require 'katello_events/candlepin/client_factory'
require 'katello_events/candlepin/listener'
require 'katello_events/heartbeat'
require 'syslog/logger'

logger = Syslog::Logger.new('katello-candlepin-events')
# logger = Logger.new($stdout)

listener = KatelloEvents::Candlepin::Listener.new(
  logger: logger
)

at_exit do
  listener.stop
end

heartbeat = KatelloEvents::Heartbeat.new(
  interval: ENV['HEARTBEAT_INTERVAL'].to_i,
  service: listener,
  logger: logger
)

loop do
  listener.start
  heartbeat.trigger
  sleep 1
end
