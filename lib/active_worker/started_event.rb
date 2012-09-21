module ActiveWorker
  class StartedEvent < ActiveWorker::Event
    def generate_message
      "#{configuration.event_name} started"
    end

    after_create :notify_root_of_child_started

  end
end
