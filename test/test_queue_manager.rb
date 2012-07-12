require_relative "test_helper"
module ActiveWorker
  module JobQueue
    class QueueManagerTest < ActiveSupport::TestCase

      test "can extract configuration id from worker" do
        config_id = 5
        worker = mock_worker(config_id)

        extracted_id = QueueManager.new.configuration_id_from_worker(worker)
        assert_equal config_id, extracted_id
      end

      test "can create job hash from worker" do
        config_id = 5
        worker = mock_worker(config_id)

        job_hash = QueueManager.new.create_job_hash_from_worker(worker)

        expected_hash = {"host" => "localhost", "pid" => config_id.to_s, "params" => [config_id]}
        assert_equal expected_hash, job_hash
      end

      test "can get list of active jobs" do
        manager = QueueManager.new

        Resque.expects(:working).returns(mock_workers)

        jobs = manager.active_jobs(configuration_ids)

        assert_equal 4, jobs.size
        assert_equal [1,2,3,4], jobs.map {|j| j["pid"].to_i}

      end

      def mock_workers
        workers = []
        10.times do |num|
          workers << mock_worker(num)
        end
        workers
      end

      def configuration_ids
        [1,2,3,4,20]
      end

      def mock_worker(config_id)
        args = [{"params" => [config_id]}]
        job = {"payload" => {"args" => args}}

        worker = mock
        worker.stubs(:job).returns(job)
        worker.stubs(:hostname).returns("localhost")
        worker.stubs(:to_s).returns("localhost:#{config_id}:*")
        worker
      end





    end
  end
end