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

      def pids
        @pids ||= []
      end

      def threads
        @threads ||= []
      end

      def execute_concurrently(params)
        new_threads = params.map do |param|
          case local_worker_mode
            when THREADED_MODE
              execute_thread param
            when FORKING_MODE
              execute_fork param
          end
        end

        threads.concat new_threads
        new_threads
      end

      def wait_for_children
        threads.each do |thread|
          thread.join if thread
        end

        cleanup_after_children
      end

      def cleanup_after_children
        @pids = []
        @threads = []
      end

      def kill_children
        pids.each do |pid|
          begin
            Process.kill("TERM", pid) if pid
          rescue Errno::ESRCH
            puts "PID: #{pid} did not exist when we went to kill it"
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
        pids << pid
        Process.detach(pid)
      end

      def in_thread(param)
        execute(param)
      end

      def in_fork(param)
        after_fork(param)
        execute(param)
      end

      def after_fork(param)
        cleanup_after_children
        set_process_name(param)
        reset_mongoid
        reset_resque
      end

      def set_process_name(param)
        $0 = "ActiveWorker Forked from #{Process.ppid} for #{param}"
      end

      def reset_mongoid
        Mongoid::Sessions.clear
      end

      def reset_resque
        Resque.redis.client.reconnect
        trap("TERM", "DEFAULT")
      end

    end
  end

end
