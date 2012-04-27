module ActiveWorker
  class FinishedEvent < ActiveWorker::Event
    def generate_message
      "#{configuration.class.event_name} finished"
    end
  end
end
