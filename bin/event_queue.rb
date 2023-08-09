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

loop do
  poller.tick

  sleep 2
end
