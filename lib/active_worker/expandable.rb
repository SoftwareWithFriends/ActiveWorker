module ActiveWorker
  module Expandable

    def self.included(base)
      base.template_field :number_of_threads, type: Integer, default: 1
      base.template_field :number_of_workers, type: Integer, default: 1
    end

    def expand_for_workers
      expand_configuration(workers_to_expand)
    end

    def expand_for_threads
      expand_configuration(threads_to_expand)
    end

    def expand_configuration(additional_configurations)
      expanded_configs = [self]
      additional_configurations.times do
        expanded_configs << created_expanded_configuration
      end
      expanded_configs
    end

    def created_expanded_configuration(options = {})
      self.class.create(defined_fields.merge(parent_configuration: parent_configuration,
                                             root_object_id: root_object_id).merge(options))
    end

    def workers_to_expand
      (number_of_workers - 1)
    end

    def threads_to_expand
      (number_of_threads - 1)
    end

  end
end