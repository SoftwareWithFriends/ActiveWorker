module ActiveWorker
  module JobQueue
    class QueueManager

      def active_jobs
        Resque.working.map {|w| create_job_hash_from_worker(w)}.compact
      end

      def active_jobs_for_configurations(configuration_ids)
        workers = Resque.working.select do|w|
          configuration_ids.include? configuration_id_from_worker(w)
        end
        workers.map do |w|
          create_job_hash_from_worker(w)
        end
      end

      def configuration_id_from_worker(worker)
        params = params_from_worker(worker)
        params.first if params
      end

      def create_job_hash_from_worker(worker)
        worker_id = worker.to_s.split(":")
        host = worker_id[0]
        pid = worker_id[1]
        queues = worker_id[2].split(",")
        args = args_from_worker(worker)

        if worker_id && host && pid && queues && args
          return {"host" => host, "queues" => queues, "pid" => pid, "args" => args }
        end
      end

      def params_from_worker(worker)
        args = args_from_worker(worker)
        args["params"] if args
      end

      def args_from_worker(worker)
        payload = worker.job["payload"]
        payload["args"].first if payload
      end
    end
  end
end