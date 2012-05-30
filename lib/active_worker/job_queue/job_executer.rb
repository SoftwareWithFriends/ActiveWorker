module ActiveWorker
  module JobQueue
    class JobExecuter
      Thread.abort_on_exception = true

      @queue = :execute

      def self.perform(args)
        execute_task_from_args(args)
      end


      def self.execute_task_from_args(args)
        class_name = args["class_name"]
        method     = args["method"]
        params     = args["params"]

        klass = class_name.constantize
        klass.send(method,*params)
      rescue Exception => e
        begin
          log_error "Creating Failure event for #{klass} because #{e.message}"
          klass.handle_error e, method, params
        rescue Exception => handle_error_error
          log_error "Handle error exception: #{handle_error_error.message}"
          log_error handle_error_error.backtrace.join("\n")
        end
      end

      def self.log_error(message)
        Rails.logger.error(message)
      end

    end
  end
end