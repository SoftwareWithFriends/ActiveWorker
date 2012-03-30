require_relative "test_helper"
module ActiveWorker
  module JobQueue
    class JobExecuterTest < ActiveSupport::TestCase

      class TestClass
        def self.test_method(param1, param2)

        end
      end

      test "can execute command from args" do
        param1 = 1
        param2 = 2
        TestClass.expects(:test_method).with(param1, param2)

        class_name = TestClass.to_s
        method     = :test_method
        params     = [param1,param2]

        args = {}
        args["class_name"] = class_name
        args["method"] = method
        args["params"] = params

        JobExecuter.execute_task_from_args(args)
      end

    end
  end
end