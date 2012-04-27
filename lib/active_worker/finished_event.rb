module ActiveWorker
  class FinishedEvent < ActiveWorker::Event
    def generate_message
      "#{configuration.class.display_name} finished"
    end
  end
end
