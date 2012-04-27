module ActiveWorker
  class StartedEvent < ActiveWorker::Event
    def generate_message
      "#{configuration.class.display_name} started"
    end
  end
end
