module ActiveWorker
  class FailureEvent < ActiveWorker::FinishedEvent

    field :stack_trace
    field :error_type

    def self.from_error(thread_root_configuration, error)
      events = []
      thread_root_configuration.configurations_for_events.each do |configuration|
        events << create_error_from_configuration(configuration,error) unless configuration.completed?
      end
      events
    end

    def self.create_error_from_configuration(configuration, error)
      constructor_options = {
          :message => "#{configuration.event_name} FAILED: #{error.message}",
          :stack_trace => error.backtrace.join("\n"),
          :configuration => configuration,
          :error_type => error.class.name
      }
      create! constructor_options
    end

  end
end