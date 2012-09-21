module ActiveWorker
  module Behavior
    module HasRootObject

      module ClassExtensions
        def root_object_relation(relation)
          belongs_to :root_object, :polymorphic => true, inverse_of: relation
        end
      end

      def self.included(base)
        base.extend(ClassExtensions)
        base.before_save :set_root_object
        base.index({:root_object_id => -1}, {:background => true})
      end

      def root_owner
        nil
      end

      def notify_root_of_child_started
        if root_object
          root_object.child_started
          root_object.save!
        end
      end

      def notify_root_of_finished
        if root_object
          root_object.child_finished
          root_object.save!
        end
      end

      def get_root_object_id
        return root_object_id if root_object_id
        set_root_object
        root_object_id
      end

      def set_root_object
        return unless root_owner
        self.root_object_id = root_owner.get_root_object_id
        self.root_object_type = root_owner.root_object_type
        true
      end

    end
  end
end
