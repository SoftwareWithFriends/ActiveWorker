module ActiveWorker
  class Controller
    extend JobQueue::RunRemotely

    attr_reader :configuration

    def self.launch_thread(configuration_id, *args)
      config = Configuration.find(configuration_id)
      worker = new(config, *args)
      worker.started
      worker.execute
      worker.finished
    end

    def self.handle_error(error, method, params)
      configuration_id = params.shift
      configuration = Configuration.find(configuration_id)
      FailureEvent.from_error(configuration, error)
    end

    def initialize(configuration)
      @configuration = configuration
      setup
    end

    def setup

    end

    def started
      configuration.started
    end

    def execute
      raise "Can't call execute on base controller #{configuration.inspect}'"
    end

    def finished
     configuration.finished
    end

    private

    def finished?(configurations)
      FinishedEvent.exists_for_configurations?(configurations)
    end

  end
end