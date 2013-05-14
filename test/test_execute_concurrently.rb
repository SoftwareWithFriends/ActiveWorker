require_relative "test_helper"

module ActiveWorker
  module Behavior
    class ExecuteConcurrentlyTest < ActiveSupport::TestCase

      class ThreadedConfig < Configuration
        include Expandable
      end

      class FakeController
        extend ExecuteConcurrently

        class FakeControllerException < StandardError;
        end

        def self.execute(param)
        end

        def self.handle_error(error, method, params)
          puts "#{error} #{method} #{params}"
        end

        def execute
        end
      end

      teardown do
        FakeController.role = nil
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
        FakeController.after_fork(nil)
      end

      test "after_fork sets mode" do
        FakeController.after_fork(nil)
        assert_equal FORKED, FakeController.role
      end

      test "after fork sets process name" do
        param = "foo"
        FakeController.expects(:set_process_name).with(param)
        FakeController.after_fork(param)

      end

      test "can set process name" do
        param = "foo"
        FakeController.after_fork(param)
        assert_equal "ActiveWorker Forked from #{Process.ppid} for foo", $0

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
        FakeController.expects(:trap).with("TERM", "DEFAULT")
        FakeController.reset_resque
      end


      test "can handle exception in fork" do
        FakeController.expects(:execute).raises(StandardError)
        FakeController.expects(:handle_error)
        FakeController.in_fork(:foo)
      end

      test "can handle signal exception in fork" do
        FakeController.expects(:execute).raises(SignalException.new("TERM"))
        FakeController.expects(:handle_termination)
        FakeController.expects(:exit)

        FakeController.in_fork(:foo)
      end


    end
  end
end