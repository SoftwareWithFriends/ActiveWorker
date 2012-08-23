module ActiveWorker
  module Behavior
    module Hashable

      def get_as_flat_hash_by_root_object(root_object)
        configs = []
        col = get_mongoid_collection
        col.find("root_object_id" => root_object.id).each do |config|
          canonicalize(config, col)
          configs << config
        end
        configs
      end

      def get_as_hash_by_root_object(root_object)
        configs = []
        col = get_mongoid_collection
        col.find("root_object_id" => root_object.id, "parent_configuration_id" => nil).each do |config|
          config["configurations"] = get_children_for(col, config["_id"])
          canonicalize(config, col)
          configs << config
        end
        configs
      end

      def get_children_for(col, parent_configuration_id)
        configs = []
        col.find("parent_configuration_id" => parent_configuration_id).each do |config|
          config["configurations"] = get_children_for(col, config["_id"])
          canonicalize(config, col)
          configs << config
        end
        configs
      end



      def get_renderable_hash_by_root_object(root_object)
        configs = []
        col = get_mongoid_collection
        col.find("root_object_id" => root_object.id, "parent_configuration_id" => nil, "renderable" => true).each do |config|
          config["configurations"] = get_renderable_children_for(col, config["_id"])
          canonicalize(config, col)
          configs << config
        end
        configs
      end

      def renderable_hash_for_configuration(configuration_id)
        col = get_mongoid_collection
        config = col.find("_id" => configuration_id).first
        config["configurations"] = get_renderable_children_for(col, config["_id"])
        canonicalize(config, col)
        config
      end

      def get_renderable_children_for(col, parent_configuration_id)
        configs = []
        col.find("parent_configuration_id" => parent_configuration_id, "renderable" => true).each do |config|
          config["configurations"] = get_renderable_children_for(col, config["_id"])
          canonicalize(config, col)
          configs << config
        end
        configs
      end

      def canonicalize(config, col)
        config["_type"] ||= col.name.classify
        config["_id"] = config["_id"].to_s
      end


      def get_mongoid_collection
        Mongoid.default_session.collections.select {|c| c.name == self.collection_name.to_s }.first
      end

    end
  end
end