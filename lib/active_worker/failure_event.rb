module ActiveWorker
  class FailureEvent < ActiveWorker::FinishedEvent

    field :stack_trace, :type => String

    def self.from_error(configuration, error)
      constructor_options = {
          :message => "#{self}: #{error.message}",
          :stack_trace => error.backtrace.join("\n"),
          :host => HostInformation.hostname,
          :configuration => configuration,
      }
      create! constructor_options
    end

  end
end