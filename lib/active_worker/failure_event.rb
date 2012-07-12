module ActiveWorker
  class FailureEvent < ActiveWorker::FinishedEvent

    field :stack_trace
    field :error_type

    def self.from_error(configuration, error)
      constructor_options = {
          :message => "#{configuration.event_name} FAILED: #{error.message}",
          :stack_trace => error.backtrace.join("\n"),
          :configuration => configuration,
          :error_type => error.class.name
      }
      create! constructor_options
    end

    def self.from_termination(configuration)
      constructor_options = {
          :message => "#{configuration.event_name} was terminated",
          :configuration => configuration,
      }
      create! constructor_options
    end

  end
end