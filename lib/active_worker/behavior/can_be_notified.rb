module ActiveWorker
  module Behavior
    module CanBeNotified

      module ClassMethods
        SLEEP_DURATION = 5

        def process_notifications(initial_configuration, thread_expanded_configurations)
          if initial_configuration.wait_for_notifications
            sleep SLEEP_DURATION until initial_configuration.notified?
            thread_expanded_configurations.map(&:notify)
          end
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
        base.after_thread_launch :process_notifications
      end

    end
  end
end