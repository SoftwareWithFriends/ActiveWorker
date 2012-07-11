module ActiveWorker
  module JobQueue
    module RunRemotely

      THREADED = "threaded"
      STALKER  = "stalker"
      RESQUE   = "resque"


      def self.worker_mode=(mode)
        @@worker_mode = mode
      end

      def self.worker_mode
        @@worker_mode
      end

      self.worker_mode = RESQUE

      class RemoteRunner
        def initialize(host,klass)
          @host = host
          @klass = klass
        end

        def method_missing(method,*params)
          args = construct_args(method,params)
          case RunRemotely.worker_mode
            when THREADED
              Thread.new do
                ActiveWorker::JobQueue::JobExecuter.execute_task_from_args(args)
              end
            when STALKER
              Stalker.enqueue(queue,args,{:ttr => 0})
            when RESQUE
              Resque.enqueue(JobExecuter,args)
          end
        end

        def queue
          @host ? "#{@host}.execute.task" : "execute.task"
        end

        def construct_args(method, params)
          {
              "class_name" => @klass.to_s,
              "method"     => method.to_s,
              "params"     => params
          }
        end
      end

      def run_remotely(host = nil)
        RemoteRunner.new(host,self.to_s)
      end
    end
  end
end