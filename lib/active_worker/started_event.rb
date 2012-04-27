module ActiveWorker
  class StartedEvent < ActiveWorker::Event
    def generate_message
      "#{configuration.class.event_name} started"
    end
  end
end
