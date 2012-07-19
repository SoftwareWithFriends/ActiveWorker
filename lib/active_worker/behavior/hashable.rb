module ActiveWorker
  module Behavior
    module Hashable

      def get_as_hash_by_root_object(root_object)
        configs = []
        col = get_mongoid_collection
        col.find("root_object_id" => root_object.id, "parent_configuration_id" => nil).each do |config|
          set_type(config, col)
          config["configurations"] = get_children_for(col, config["_id"])
          configs << config
        end
        configs
      end

      def get_children_for(col, parent_configuration_id)
        configs = []
        col.find("parent_configuration_id" => parent_configuration_id).each do |config|
          set_type(config, col)
          config["configurations"] = get_children_for(col, config["_id"])
          configs << config
        end
        configs
      end



      def get_renderable_hash_by_root_object(root_object)
        configs = []
        col = get_mongoid_collection
        col.find("root_object_id" => root_object.id, "parent_configuration_id" => nil, "renderable" => true).each do |config|
          set_type(config, col)
          config["configurations"] = get_renderable_children_for(col, config["_id"])
          configs << config
        end
        configs
      end

      def renderable_hash_for_configuration(configuration_id)
        col = get_mongoid_collection
        config = col.find("_id" => configuration_id).first
        set_type(config, col)
        config["configurations"] = get_renderable_children_for(col, config["_id"])
        config
      end

      def get_renderable_children_for(col, parent_configuration_id)
        configs = []
        col.find("parent_configuration_id" => parent_configuration_id, "renderable" => true).each do |config|
          set_type(config, col)
          config["configurations"] = get_renderable_children_for(col, config["_id"])
          configs << config
        end
        configs
      end

      def set_type(config, col)
        config["_type"] ||= col.name.classify
      end


      def get_mongoid_collection
        Mongoid.default_session.collections.select {|c| c.name == self.collection_name.to_s }.first
      end

    end
  end
end