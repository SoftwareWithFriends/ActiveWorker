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
        RunRemotely.worker_mode = RunRemotely::RESQUE
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

        Resque.expects(:enqueue).with(JobExecuter,args)

        TestClass.run_remotely.test_method(param1,param2)
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


    end

  end
end