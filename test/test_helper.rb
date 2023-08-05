require 'minitest/autorun'
require 'mocha/minitest'
require 'logger'
require 'openssl'
require 'webmock/minitest'

$LOAD_PATH.unshift File.expand_path('../../lib/', __FILE__)

ENV['KATELLO_URI'] = 'https://katello.example.com'
ENV['SSL_CLIENT_CERT'] = '/tmp/test_katello_events_client_cert.pem'
ENV['SSL_CLIENT_KEY'] = '/tmp/test_katello_events_client_key.pem'

subject = '/O=Test/OU=Test/CN=Test'
subject_name = OpenSSL::X509::Name.parse(subject)
key = OpenSSL::PKey::RSA.new(4096)

cert = OpenSSL::X509::Certificate.new
cert.public_key = key.public_key
cert.subject = subject_name
cert.issuer = subject_name
cert.not_before = Time.now
cert.not_after = Time.now + 30
cert.sign key, OpenSSL::Digest::SHA256.new

File.write(ENV['SSL_CLIENT_CERT'], cert.to_pem)
File.write(ENV['SSL_CLIENT_KEY'], key.to_pem)

TEST_LOGGER = Logger.new($stdout)

def stub_katello_request(endpoint)
  stub_request(:post, "https://katello.example.com#{endpoint}").
    with(
      headers: {
	    'Content-Type'=>'application/json',
	    'Host'=>'katello.example.com'
      })
end
