require_relative "test_helper"

module ActiveWorker
  class ControllerTest < ActiveSupport::TestCase

    test "can create started event" do
      configuration = Configuration.create
      controller = Controller.new(configuration)
      controller.started
      assert_equal 1, StartedEvent.where(configuration_id: configuration.id).size
    end

    test "creates started event during execute_worker" do

      configuration = Configuration.create

      Controller.any_instance.stubs(:execute)
      Controller.execute_worker(configuration.id)

      assert_equal 1, StartedEvent.where(configuration_id: configuration.id).size
    end

    test "can run multiple threads" do
      class ThreadedConfig < Configuration
        include Expandable
      end
      configuration = ThreadedConfig.create number_of_threads: 2

      old_mode = Controller::local_worker_mode
      Controller::local_worker_mode = Controller::THREADED_MODE

      Controller.any_instance.expects(:execute).twice
      Controller.execute_worker(configuration.id)

      Controller::local_worker_mode = old_mode
    end

    test "creates finished event during execute_worker" do

      configuration = Configuration.create

      Controller.any_instance.stubs(:execute)
      Controller.execute_worker(configuration.id)

      assert_equal 1, FinishedEvent.where(configuration_id: configuration.id).size

    end

    test "calls setup during initialization" do
      Controller.any_instance.expects(:setup)
      configuration = Configuration.create
      controller = Controller.new(configuration)
      controller.started
      assert_equal 1, StartedEvent.where(configuration_id: configuration.id).size
    end

    test "call worker cleanup methods during launch thread" do
      class TestController < Controller
        worker_cleanup :test_worker_cleanup_method

        def execute

        end
      end
      configuration = Configuration.create

      TestController.expects(:test_worker_cleanup_method)
      TestController.execute_worker(configuration.id)
    end
  end
end