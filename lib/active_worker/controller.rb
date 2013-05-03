module ActiveWorker
  class Controller
    extend JobQueue::RunRemotely

    attr_reader :configuration

    THREADED_MODE = :local_worker_thread
    FORKING_MODE =  :local_worker_fork

    def self.local_worker_mode
      @@local_worker_mode
    end

    def self.local_worker_mode=(mode)
      @@local_worker_mode = mode
    end

    self.local_worker_mode = FORKING_MODE

    def self.execute_worker(configuration_id)
      config = Configuration.find(configuration_id)
      configurations = config.expand_for_threads
      execute_local_workers(config, configurations)
    ensure
      worker_cleanup_methods.each { |method| send(method, configurations) }
    end

    def self.execute_local_workers(config, configurations)
      threads = execute_expanded_configurations configurations
      after_thread_launch_methods.each { |method| send(method, config, configurations) }
      threads.each(&:join)
    end

    def self.execute_expanded_configurations(configurations)
      configurations.map do |expanded_config|
        case local_worker_mode
          when THREADED_MODE
            execute_thread expanded_config
          when FORKING_MODE
            execute_fork expanded_config
        end
      end
    end

    def self.execute_thread(configuration)
      Thread.new do
        workflow(configuration)
      end
    end

    def self.execute_fork(configuration)
      pid =  fork do
        handle_forking
        workflow(configuration)
      end
      Process.detach(pid)
    end

    def self.workflow(configuration)
      worker = new(configuration)
      worker.started
      worker.execute
      worker.finished
    end

    def self.handle_forking
      Mongoid::Sessions.clear
      Resque.redis = clone_redis_connection(Resque.redis)
    end

    def self.clone_redis_connection(redis)
      Redis.new(host: redis.client.host, port: redis.client.port)
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