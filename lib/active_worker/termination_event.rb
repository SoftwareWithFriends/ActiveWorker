module ActiveWorker
  class TerminationEvent < ActiveWorker::FinishedEvent

    def self.from_termination(configuration)
      constructor_options = {
          :message => "#{configuration.event_name} was terminated",
          :configuration => configuration,
      }
      create! constructor_options
    end

  end
end