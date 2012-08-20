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

        expected_hash = {"host" => "localhost",
                         "queues" => ["execute", "localhost_execute"],
                         "pid" => config_id.to_s,
                         "args" => {"params" => [config_id]}}

        assert_equal expected_hash, job_hash
      end

      test "can get list of active jobs for configurations" do
        manager = QueueManager.new

        Resque.expects(:working).returns(mock_workers)

        jobs = manager.active_jobs_for_configurations(configuration_ids)

        assert_equal 4, jobs.size
        assert_equal [1, 2, 3, 4], jobs.map { |j| j["pid"].to_i }

      end

      test "does not report on jobless workers" do
        config_id = 5
        worker = mock_worker(config_id, {})

        job_hash = QueueManager.new.create_job_hash_from_worker(worker)

        assert_nil job_hash

      end

      test "active workers can lose their jobs" do
        manager = QueueManager.new

        workers = mock_workers + [mock_worker(11, {})]

        Resque.expects(:working).returns(workers)

        ids = configuration_ids + [11]

        jobs = manager.active_jobs_for_configurations(ids)

        assert_equal 4, jobs.size
        assert_equal [1, 2, 3, 4], jobs.map { |j| j["pid"].to_i }
      end

      test "does not return workers without jobs" do
        manager = QueueManager.new

        workers = mock_workers(4) + [mock_worker(11, {})]

        Resque.expects(:working).returns(workers)

        jobs = manager.active_jobs

        assert_equal 4, jobs.size
        assert_equal [0, 1, 2, 3], jobs.map { |j| j["pid"].to_i }
      end

      def mock_workers(num_workers = 10)
        workers = []
        num_workers.times do |num|
          workers << mock_worker(num)
        end
        workers
      end

      def configuration_ids
        [1, 2, 3, 4, 20]
      end

      def mock_worker(config_id, job = mock_job(config_id))
        worker = mock
        worker.stubs(:job).returns(job)
        worker.stubs(:hostname).returns("bad_hostname")
        worker.stubs(:to_s).returns("localhost:#{config_id}:execute,localhost_execute")
        worker
      end

      def mock_job(config_id)
        args = [{"params" => [config_id]}]
        job = {"payload" => {"args" => args}}
      end


    end
  end
end