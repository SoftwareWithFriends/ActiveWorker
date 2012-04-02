module ActiveWorker
  class Controller
    extend ActiveWorker::JobQueue::RunRemotely

    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
    end

    def finished?(finished_class, count = feed_count)
      finished_class.for_top_level_configuration(configuration).count >= count
    end

    def execute
      raise "Can't call execute on base controller #{configuration.inspect}'"
    end

    def finished
      FinishedEvent.create configuration: configuration
    end
  end
end