module ActiveWorker
  module JobQueue
    module RunRemotely

      class RemoteRunner
        def initialize(host,klass)
          @host = host
          @klass = klass
        end

        def method_missing(method,*params)
          args = construct_args(method,params)
          Stalker.enqueue(queue,args,{:ttr => 0})
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

      def launch_thread(configuration_id, *args)
        worker = new(ActiveWorker::Configuration.find(configuration_id), *args)
        worker.execute
        worker.finished
      end

      def run_remotely(host = nil)
        RemoteRunner.new(host,self.to_s)
      end

      def handle_error(error, method, params)
        configuration_id = params.shift
        configuration = ActiveWorker::Configuration.find(configuration_id)
        "#{self.parent}::FailureEvent".constantize.from_error(configuration, error)
      end
    end
  end
end