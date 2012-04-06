module ActiveWorker
  module Behavior
    module ActsAsRootObject

      module ClassExtensions
        def acts_as_root_for(relation,class_name)
          has_many   relation, :dependent => :destroy,
                     :class_name => class_name,
                     :inverse_of => :root_object,
                     :autosave   => true
        end
      end

      def self.included(base)
        base.extend(ClassExtensions)
        base.field :root_object_finished, :type => Boolean, :default => false
        base.acts_as_root_for :configurations, "ActiveWorker::Configuration"
        base.acts_as_root_for :events, "ActiveWorker::Event"
      end

      def completed?
        self.root_object_finished ||= calculate_completed
      end

      def calculate_completed
        immediate_child_configurations.each do |config|
          return false unless config.completed?
        end
        true
      end

      def renderable_configurations
        immediate_child_configurations.select {|c| c.renderable}
      end

      def immediate_child_configurations
        configurations.where(parent_configuration_id: nil)
      end

      def renderable_configuration_hashes
        @renderable_configurations_hash ||= ActiveWorker::Configuration.get_renderable_hash_by_root_object(self)
      end
    end
  end
end