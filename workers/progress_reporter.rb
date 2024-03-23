# frozen_string_literal: true

require 'http'

module Appraisal
  # Reports progress as percent to Faye endpoint
  class ProgressReporter
    def initialize(config, channel_id)
      @config = config
      @channel_id = channel_id
    end

    def publish(message, state, channel_id = '')
      print "Progress: #{message} "
      print "[post: #{@config.API_HOST}/faye] "
      response = HTTP.headers(content_type: 'application/json')
                     .post(
                       "#{@config.API_HOST}/faye",
                       body: message_body(message, state, channel_id)
                     )
      puts "(#{response.status})"
    rescue HTTP::ConnectionError
      puts '(Faye server not found - progress not sent)'
    end

    private

    def message_body(message, state, channel_id)
      data = {
        message: message,
        state: state,
        channel_id: channel_id
      }
      { channel: "/#{@channel_id}",
        data: data }.to_json
    end
  end
end
