module ActiveWorker
  module JobQueue
    module RunRemotely

      THREADED = "threaded"
      RESQUE   = "resque"


      def self.worker_mode=(mode)
        @@worker_mode = mode
      end

      def self.worker_mode
        @@worker_mode
      end

      self.worker_mode = RESQUE

      class RemoteRunner
        def initialize(klass)
          @klass = klass
        end

        def method_missing(method,*params)
          args = construct_args(method,params)
          thread = nil
          case RunRemotely.worker_mode
            when THREADED
              thread = Thread.new do
                ActiveWorker::JobQueue::JobExecuter.execute_task_from_args(args)
              end
            when RESQUE
              Resque.enqueue(JobExecuter,args)
          end
          thread
        end

        def construct_args(method, params)
          {
              "class_name" => @klass.to_s,
              "method"     => method.to_s,
              "params"     => params
          }
        end
      end

      def run_remotely
        RemoteRunner.new(self.to_s)
      end
    end
  end
end