require_relative "test_helper"
module ActiveWorker
  module JobQueue
    class RunRemotelyTest < ActiveSupport::TestCase

      class TestClass
        extend RunRemotely

        def self.test_method(param1, param2)
        end

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
    end
  end

end