module ActiveWorker
  module JobQueue
    class JobExecuter
      def self.execute_task_from_args(args)
        class_name = args["class_name"]
        method     = args["method"]
        params     = args["params"]

        klass = class_name.constantize
        klass.send(method,*params)
      rescue Exception => e
        begin
          Rails.logger.error "Creating Failure event for #{klass} because #{e.message}"
          klass.handle_error e, method, params
        rescue => handle_error_error
          Rails.logger.error "Handle error exception: #{handle_error_error.message}"
          Rails.logger.error handle_error_error.backtrace.join("\n")
        end
      end
    end
  end
end