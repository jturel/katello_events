require_relative 'lib/katello_events/version'

Gem::Specification.new do |s|
  s.name = 'katello_events'
  s.version = KatelloEvents::VERSION
  s.summary = 'Handles the different asynchronous events processing for Katello'
  s.authors = 'Jonathon Turel'
  s.files = Dir[
    'lib/katello_events/katello_events.rb',
    'lib/katello_events/**/*'
  ]

  s.add_runtime_dependency 'stomp'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'webmock'
end
