module ActiveWorker
  module Behavior
    module ActsAsRootObject

      module ClassExtensions
        def acts_as_root_for(relation, class_name)
          has_many relation, :dependent => :delete,
                   :class_name => class_name,
                   :as => :root_object,
                   :autosave => true
        end
      end

      def self.included(base)
        base.extend(ClassExtensions)
        base.send(:include, Mongoid::Timestamps)
        base.field :root_object_finished, :type => Boolean, :default => false
        base.field :finished_at, :type => Time
        base.field :flags, :type => Hash, :default => {}
        base.before_save :set_flags
        base.acts_as_root_for :configurations, "ActiveWorker::Configuration"
        base.acts_as_root_for :events, "ActiveWorker::Event"
      end

      def duration
        if completed? && finished_at
          return finished_at - created_at
        end

        if completed? && !finished_at
          return 0
        end

        Time.now - created_at
      end

      def completed?
        self.root_object_finished
      end

      def child_started
        self.root_object_finished = false
      end

      def child_finished
        self.root_object_finished = calculate_completed
      end

      def calculate_completed
        immediate_child_configurations.each do |config|
          return false unless config.completed?
        end
        self.finished_at = Time.now
        true
      end

      def renderable_configurations
        immediate_child_configurations.select { |c| c.renderable }
      end

      def immediate_child_configurations
        configurations.where(parent_configuration_id: nil)
      end

      def renderable_configuration_hashes
        @renderable_configurations_hash ||= ActiveWorker::Configuration.get_renderable_hash_by_root_object(self)
      end

      def all_configuration_hashes
        @renderable_configurations_hash ||= ActiveWorker::Configuration.get_as_flat_hash_by_root_object(self)
      end

      def set_flags
        immediate_child_configurations.each do |config|
          config.update_attributes(:flags => flags)
        end
      end
    end
  end
end