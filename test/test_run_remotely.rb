require_relative "test_helper"
module ActiveWorker
  module JobQueue
    class RunRemotelyTest < ActiveSupport::TestCase

      class TestClass
        extend RunRemotely

        def self.test_method(param1, param2)
        end

      end

      setup do
        RunRemotely.worker_mode = RunRemotely::STALKER
      end

      test "correctly enqueues jobs with no host" do
        param1 = 1
        param2 = 2

        class_name = TestClass.to_s
        method     = "test_method"
        params     = [param1,param2]

        args = {}
        args["class_name"] = class_name
        args["method"] = method
        args["params"] = params

        Stalker.expects(:enqueue).with("execute.task",args,{:ttr => 0})

        RunRemotely.worker_mode

        TestClass.run_remotely.test_method(param1,param2)
      end

      test "correctly enqueues jobs with host" do
        param1 = 1
        param2 = 2

        class_name = TestClass.to_s
        method     = "test_method"
        params     = [param1,param2]

        args = {}
        args["class_name"] = class_name
        args["method"] = method
        args["params"] = params

        Stalker.expects(:enqueue).with("host1.execute.task",args,{:ttr => 0})

        TestClass.run_remotely("host1").test_method(param1,param2)
      end

      test "puts stack trace on FailureEvent from error" do
        config = ActiveWorker::Configuration.create

        exception = create_exception
        ActiveWorker::Controller.handle_error(exception,:create, [config.id])

        event = ActiveWorker::FailureEvent.where(:configuration_id => config.id).first

        assert_match exception.message, event.message
        assert_equal exception.backtrace.join("\n"), event.stack_trace
      end

      test "can set worker mode to threaded" do
        param1 = 1
        param2 = 2

        class_name = TestClass.to_s
        method     = "test_method"
        params     = [param1,param2]

        args = {}
        args["class_name"] = class_name
        args["method"] = method
        args["params"] = params

        RunRemotely.worker_mode = RunRemotely::THREADED

        TestClass.expects(:test_method)

        thread = TestClass.run_remotely.test_method(param1,param2)
        thread.join
      end

      test "exceptions are handled in every thread" do
        begin

          ct = Thread.new do
            begin
              gt = Thread.new do
                raise
              end
              gt.join
              sleep(10)
            rescue Exception => e
              puts "\nhandle from child"
            end
          end
          ct.join
          sleep(10)
        rescue Exception => e
          puts "\nhandle from main thread"
        end
        #sleep(1)
      end
    end

  end
end