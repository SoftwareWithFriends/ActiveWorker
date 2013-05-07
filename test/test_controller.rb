require_relative "test_helper"

module ActiveWorker
  class ControllerTest < ActiveSupport::TestCase

    class ThreadedConfig < Configuration
      include Expandable
    end

    test "can create started event" do
      configuration = Configuration.create
      controller = Controller.new(configuration)
      controller.started
      assert_equal 1, StartedEvent.where(configuration_id: configuration.id).size
    end

    test "creates started event during execution" do

      configuration = Configuration.create

      Controller.any_instance.stubs(:execute)
      Controller.execute(configuration)

      assert_equal 1, StartedEvent.where(configuration_id: configuration.id).size
    end

    test "can run concurrently in threads" do
      number_of_threads = 2
      configuration = ThreadedConfig.create number_of_threads: number_of_threads

      Controller::local_worker_mode = THREADED_MODE

      Controller.any_instance.expects(:execute).twice
      Controller.execute_expanded(configuration.id)

      assert_equal 0, FailureEvent.count
      assert_equal number_of_threads, StartedEvent.count
      assert_equal number_of_threads, FinishedEvent.count

    end

    test "can run concurrently in forks" do

      number_of_threads = 2
      configuration = ThreadedConfig.create number_of_threads: number_of_threads

      assert_equal FORKING_MODE, Controller::local_worker_mode

      Controller.any_instance.stubs(:execute)
      Controller.execute_expanded(configuration.id)

      assert_equal 0, FailureEvent.count
      assert_equal number_of_threads, StartedEvent.count
      assert_equal number_of_threads, FinishedEvent.count
    end

    test "creates finished event during execution" do

      configuration = Configuration.create

      Controller.any_instance.stubs(:execute)
      Controller.execute(configuration)

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
      TestController.execute_expanded(configuration.id)
    end
  end
end