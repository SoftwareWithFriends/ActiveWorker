require 'net/http'
require 'uri'

module TestWorker
  class HttpRunner

    attr_reader :uri

    def initialize(url)
      @uri = URI.parse(url)
    end

    def get_for(duration, sleep_time)
      start = Time.new
      until start + duration < Time.new
        request_started = Time.new
        response = Net::HTTP.get_response(uri)
        puts "Duration: #{Time.new - request_started} Code: #{response.code} Message: #{response.msg}"
        sleep sleep_time
      end
    end
  end
end