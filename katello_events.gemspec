# frozen_string_literal: true

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
  s.required_ruby_version = '>= 2.7.0'

  s.add_runtime_dependency 'stomp', '< 1.5'
  s.add_runtime_dependency 'pg', '< 2.0'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'webmock'
  s.metadata['rubygems_mfa_required'] = 'true'
end
