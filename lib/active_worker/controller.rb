module ActiveWorker
  class Controller
    extend Behavior::ExecuteConcurrently
    extend JobQueue::RunRemotely

    attr_reader :configuration

    def self.execute_expanded(configuration_id)
      config = Configuration.find(configuration_id)
      configurations = config.expand_for_threads

      execute_concurrently(configurations)

      after_thread_launch_methods.each { |method| send(method, config, configurations) }

      wait_for_children
    ensure
      worker_cleanup_methods.each { |method| send(method, configurations) }
    end

    def self.execute(configuration)
      worker = new(configuration)
      worker.started
      worker.execute
      worker.finished
    end

    def self.handle_error(error, method, params)
      configuration_id = params.shift
      configuration = Configuration.find(configuration_id)

      if threaded?
        FailureEvent.from_error(configuration, error)
      end

      if forking? && parent?
        ParentEvent.create_error_from_configuration(configuration, error)
        kill_children
        wait_for_children
      end

      if forked?
        FailureEvent.create_error_from_configuration(configuration, error)
      end

    rescue Exception => e
      puts "ERROR: While Handling #{error} Had : #{e}\n#{e.backtrace.join("\n")}"
    end

    def self.handle_termination(params)
      if forking? && parent?
        kill_children
        wait_for_children
      end

      configuration_id = params.shift
      configuration = Configuration.find(configuration_id)

      if threaded?
        TerminationEvent.from_termination(configuration)
      end
      if forked?
        TerminationEvent.create_termination_from_configuration(configuration)
      end

    end

    def self.after_thread_launch(method)
      after_thread_launch_methods << method
    end

    def self.after_thread_launch_methods
      @after_thread_launch_methods ||= []
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