require 'katello_events/heartbeat'
require 'katello_events/event_queue/drainer'
require 'katello_events/event_queue/poller'
require 'syslog/logger'

logger = Syslog::Logger.new('katello-event-queue')
drainer = KatelloEvents::EventQueue::Drainer.new(logger: logger)
poller = KatelloEvents::EventQueue::Poller.new(
  logger: logger,
  drainer: drainer
)

at_exit do 
  poller.stop
end

heartbeat = KatelloEvents::Heartbeat.new(
  interval: ENV['HEARTBEAT_INTERVAL'].to_i,
  service: poller,
  logger: logger
)

loop do
  poller.tick
  heartbeat.trigger

  sleep 1
end
