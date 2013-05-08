require_relative "test_helper"

module ActiveWorker
  module Behavior
    class ExecuteConcurrentlyTest < ActiveSupport::TestCase

      class ThreadedConfig < Configuration
        include Expandable
      end

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

      test "keeps track of spawned child pids" do
        params = [1, 2]
        assert_equal FORKING_MODE, FakeController::local_worker_mode

        threads = FakeController.execute_concurrently(params)
        assert_equal params.size, threads.size
        assert_equal params.size, FakeController.pids.size
        assert_equal threads.map(&:pid), FakeController.pids
      end

      test "cleans up child pids" do
        params = [1, 2]
        assert_equal FORKING_MODE, FakeController::local_worker_mode

        FakeController.execute_concurrently(params)
        assert_equal params.size, FakeController.pids.size

        FakeController.wait_for_children
        assert_empty FakeController.pids
      end

      test "can reset resque" do
        Resque.redis.client.expects(:reconnect)
        FakeController.reset_resque
      end


    end
  end
end