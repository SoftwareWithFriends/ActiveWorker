module ActiveWorker
  class TerminationEvent < ActiveWorker::FinishedEvent

    def self.from_termination(root_configuration)
      events = []
      root_configuration.configurations_for_events.each do |configuration|
        events << create_termination_from_configuration(configuration) unless configuration.completed?
      end
      events
    end

    def self.create_termination_from_configuration(configuration)
      constructor_options = {
          :message => "#{configuration.event_name} was terminated",
          :configuration => configuration,
      }
      create! constructor_options
    end

  end
end