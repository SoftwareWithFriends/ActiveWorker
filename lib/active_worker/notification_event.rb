module ActiveWorker
  class NotificationEvent < ActiveWorker::Event

    def generate_message
      "#{configuration.event_name} has been notified"
    end

  end
end
