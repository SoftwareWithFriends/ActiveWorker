module ActiveWorker
  class FinishedEvent < ActiveWorker::Event
    def generate_message
      "#{configuration.event_name} finished"
    end
  end
end
