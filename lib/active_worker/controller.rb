module ActiveWorker
  class Controller
    extend JobQueue::RunRemotely

    attr_reader :configuration

    def self.execute_worker(configuration_id)
      config = Configuration.find(configuration_id)
      configurations = config.expand_for_threads

      threads = execute_threads configurations
      threads.each(&:join)
      worker_cleanup_methods.each { |method| send(method, configurations) }
    end

    def self.execute_threads(configurations)
      configurations.map do |expanded_config|
        execute_thread expanded_config
      end
    end

    def self.execute_thread(configuration)
      Thread.new do
        worker = new(configuration)
        worker.started
        worker.execute
        worker.finished
      end
    end

    def self.handle_error(error, method, params)
      configuration_id = params.shift
      configuration = Configuration.find(configuration_id)
      FailureEvent.from_error(configuration, error)
    end

    def self.handle_termination(params)
      configuration_id = params.shift
      configuration = Configuration.find(configuration_id)
      TerminationEvent.from_termination(configuration)
    end

    def self.worker_cleanup(method)
      worker_cleanup_methods << method
    end

    def self.worker_cleanup_methods
      @worker_cleanup_methods ||= []
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