# frozen_string_literal: true

module KatelloEvents
  class ReceivedMessage
    attr_reader :headers, :body

    def initialize(body:, headers: {})
      @body = body
      @headers = headers
    end
  end
end
