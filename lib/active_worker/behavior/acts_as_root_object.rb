module ActiveWorker
  module Behavior
    module ActsAsRootObject

      module ClassExtensions
        def acts_as_root_for(relation,class_name)
          has_many   relation, :dependent => :destroy,
                     :class_name => class_name,
                     :inverse_of => :root_object,
                     autosave: true
        end
      end

      def self.included(base)
        base.extend(ClassExtensions)
        base.acts_as_root_for :configurations, "ActiveWorker::Configuration"
        base.acts_as_root_for :events, "ActiveWorker::Event"
      end

      def completed?
        immediate_child_configurations.each do |config|
          return false unless config.completed?
        end
        true
      end

      def renderable_configurations
        immediate_child_configurations.select {|c| c.renderable?}
      end

      def immediate_child_configurations
        configurations.where(parent_configuration_id: nil)
      end
    end
  end
end