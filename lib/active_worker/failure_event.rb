module ActiveWorker
  class FailureEvent < ActiveWorker::FinishedEvent

    field :stack_trace
    field :error_type

    def self.from_error(configuration, error)
      constructor_options = {
          :message => "#{self}: #{error.message}",
          :stack_trace => error.backtrace.join("\n"),
          :configuration => configuration,
          :error_type => error.class.name
      }
      create! constructor_options
    end

  end
end