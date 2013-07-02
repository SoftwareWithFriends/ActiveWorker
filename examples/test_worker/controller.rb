module TestWorker

  class Controller < ActiveWorker::Controller

    def execute
      runner = HttpRunner.new(configuration.url)
      runner.get_for(configuration.duration, configuration.delay_between_requests)
    end

  end
end