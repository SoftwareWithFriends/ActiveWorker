module ActiveWorker
  class FailureEvent < ActiveWorker::FinishedEvent
    extend Behavior::CreateFromError

    def self.from_error(thread_root_configuration, error)
      events = []
      thread_root_configuration.configurations_for_events.each do |configuration|
        events << create_error_from_configuration(configuration,error) unless configuration.completed?
      end
      events
    end



  end
end