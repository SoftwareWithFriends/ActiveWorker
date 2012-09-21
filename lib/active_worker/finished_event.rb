module ActiveWorker
  class FinishedEvent < ActiveWorker::Event
    def generate_message
      "#{configuration.event_name} finished"
    end

    after_create :notify_root_of_finished
  end
end
