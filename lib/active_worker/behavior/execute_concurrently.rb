module ActiveWorker

  THREADED_MODE = :local_worker_thread
  FORKING_MODE = :local_worker_fork
  DEFAULT_MODE = FORKING_MODE

  module Behavior
    module ExecuteConcurrently

      def local_worker_mode=(mode)
        @@local_worker_mode = mode
      end

      def local_worker_mode
        @@local_worker_mode ||= FORKING_MODE
      end

      def execute_concurrently(params)
        params.map do |param|
          case local_worker_mode
            when THREADED_MODE
              execute_thread param
            when FORKING_MODE
              execute_fork param
          end
        end
      end

      def execute_thread(param)
        Thread.new do
          in_thread(param)
        end
      end

      def execute_fork(param)
        pid = fork do
          in_fork(param)
        end
        Process.detach(pid)
      end

      def in_thread(param)
        execute(param)
      end

      def in_fork(param)
        after_fork
        execute(param)
      end

      def after_fork
        reset_mongoid()
        reset_resque()
      end

      def reset_mongoid
        Mongoid::Sessions.clear
      end

      def reset_resque
        Resque.redis = clone_redis_connection(Resque.redis)
      end

      def clone_redis_connection(redis)
        Redis.new(host: redis.client.host, port: redis.client.port)
      end

    end
  end

end
