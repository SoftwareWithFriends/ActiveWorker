require_relative "test_helper"

module ActiveWorker
  module Behavior
    class ExecuteConcurrentlyTest < ActiveSupport::TestCase

      class FakeController
        extend ExecuteConcurrently

        def self.execute(param)

        end

        def execute

        end
      end

      test "can set threaded mode" do
        params = [1, 2]
        FakeController::local_worker_mode = THREADED_MODE
        params.each do |param|
          FakeController.expects(:execute_thread).with(param)
        end

        FakeController.execute_concurrently(params)
      end

      test "can set forking mode" do
        params = [1, 2]
        FakeController::local_worker_mode = FORKING_MODE
        params.each do |param|
          FakeController.expects(:execute_fork).with(param)
        end

        FakeController.execute_concurrently(params)
      end

      test "in_fork calls after_fork" do
        FakeController.expects(:after_fork)
        FakeController.stubs(:execute)
        FakeController.in_fork(nil)
      end

      test "after fork reset mongoid and resque" do
        FakeController.expects(:reset_mongoid)
        FakeController.expects(:reset_resque)
        FakeController.after_fork
      end

      test "can reset mongoid" do
        first_mongoid_session = Mongoid.default_session
        FakeController.reset_mongoid
        assert_not_equal first_mongoid_session, Mongoid.default_session
      end

      test "can reset resque" do
        first_redis_connection = Resque.redis
        FakeController.reset_resque
        assert_not_equal first_redis_connection, Resque.redis
      end


    end
  end
end