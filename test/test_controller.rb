require_relative "test_helper"

module ActiveWorker
  class ControllerTest < ActiveSupport::TestCase

    class ThreadedConfig < Configuration
      include Expandable
    end

    class SpawnsChildrenController < Controller
      def execute
        sleep 30
      end
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
      assert_equal 0, Controller.pids.size
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


    test "handle termination while forked" do
      number_of_threads = 2
      configuration = ThreadedConfig.create number_of_threads: number_of_threads


      thread = Thread.new do
        SpawnsChildrenController.execute_expanded(configuration.id)
      end

      sleep 0.1 until (StartedEvent.count == number_of_threads)
      SpawnsChildrenController.handle_termination([configuration.id])
      thread.join

      assert_equal number_of_threads, TerminationEvent.count

      FailureEvent.all.each do |event|
        puts event.message
      end
      assert_equal 0, FailureEvent.count

      assert_equal number_of_threads, StartedEvent.count
      assert_equal 0, ParentEvent.count
    end

    test "can handle exception while forked" do
      Controller.any_instance.stubs(:execute).raises

      number_of_threads = 2
      configuration = ThreadedConfig.create number_of_threads: number_of_threads

      assert_equal FORKING_MODE, Controller::local_worker_mode

      Controller.execute_expanded(configuration.id)

      assert_equal number_of_threads, FailureEvent.count
      assert_equal number_of_threads, StartedEvent.count
      assert_equal number_of_threads, FinishedEvent.count
      assert_equal 0, ParentEvent.count
      assert_equal 0, Controller.pids.size
    end

    test "can handle parent exception while forked" do

      number_of_threads = 2
      configuration = ThreadedConfig.create number_of_threads: number_of_threads

      thread = Thread.new do
        SpawnsChildrenController.execute_expanded(configuration.id)
      end

      error = StandardError.new
      error.expects(:backtrace).returns ["Line1", "Line2"]

      sleep 0.1 until (StartedEvent.count == number_of_threads)
      SpawnsChildrenController.handle_error(error, :test, [configuration.id])
      thread.join

      assert_equal number_of_threads, TerminationEvent.count

      assert_equal 1, ParentEvent.count
      assert_equal 0, FailureEvent.count
      assert_equal number_of_threads, StartedEvent.count

    end

    test "puts stack trace on FailureEvent from error" do
      config = Configuration.create

      exception = create_exception
      ActiveWorker::Controller.expects(:threaded?).returns(true)
      ActiveWorker::Controller.expects(:forking?).returns(false)
      ActiveWorker::Controller.handle_error(exception, :create, [config.id])

      event = ActiveWorker::FailureEvent.where(:configuration_id => config.id).first

      assert_match exception.message, event.message
      assert_equal exception.backtrace.join("\n"), event.stack_trace
    end

    test "creates error for threads when threaded" do
      config1 = ThreadedConfig.create
      config1.thread_expanded_configurations << ThreadedConfig.create

      exception = create_exception
      Controller.expects(:threaded?).returns(true)
      Controller.expects(:forking?).returns(false)
      Controller.expects(:forked?).returns(false)
      Controller.handle_error(exception, :create, [config1.id])

      assert_equal 2, FailureEvent.count

    end

    test "creates terminaion events for threads when threaded" do
      config1 = ThreadedConfig.create
      config1.thread_expanded_configurations << ThreadedConfig.create

      Controller.expects(:threaded?).returns(true)
      Controller.expects(:forking?).returns(false)
      Controller.expects(:forked?).returns(false)
      Controller.handle_termination([config1.id])

      assert_equal 2, TerminationEvent.count
    end


  end
end