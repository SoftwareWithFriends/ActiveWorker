module TestWorker
  class Configuration < ActiveWorker::Configuration

    config_field :duration, type: Integer, default: 30
    config_field :delay_between_requests, type: Float, default: 0.0
    template_field :url, type: String, default: "http://google.com"

  end
end