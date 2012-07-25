module ActiveWorker
  module Behavior
    module HasRootObject

      def self.included(base)
        base.before_save :set_root_object
        base.belongs_to :root_object, :polymorphic => true
        base.index(:root_object_id => -1)
      end

      def root_owner
        nil
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
