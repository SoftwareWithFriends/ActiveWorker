module ActiveWorker
  module Behavior
    module CreateFromError

      def self.extended(base)
        base.field :stack_trace
        base.field :error_type
      end

      def create_error_from_configuration(configuration, error)
        constructor_options = {
            :message => "#{configuration.event_name} FAILED: #{error.message}",
            :stack_trace => error.backtrace.join("\n"),
            :configuration => configuration,
            :error_type => error.class.name
        }
        create! constructor_options
      end
    end
  end
end