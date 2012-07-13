module ActiveWorker
  module JobQueue
    class QueueManager

      def active_jobs(configuration_ids)
        workers = Resque.working.select do|w|
          configuration_ids.include? configuration_id_from_worker(w)
        end
        workers.map do |w|
          create_job_hash_from_worker(w)
        end
      end

      def configuration_id_from_worker(worker)
        params_from_worker(worker).first
      end

      def create_job_hash_from_worker(worker)
        worker_id = worker.to_s.split(":")
        host = worker_id[0]
        pid = worker_id[1]
        queues = worker_id[2].split(",")
        {"host" => host, "queues" => queues, "pid" => pid, "args" =>  args_from_worker(worker)}
      end

      def params_from_worker(worker)
        args_from_worker(worker)["params"]
      end

      def args_from_worker(worker)
        worker.job["payload"]["args"].first
      end
    end
  end
end