module ActiveWorker
  module Behavior
    module Hashable

      def get_as_hash_by_root_object(root_object)
        configs = []
        col = Mongoid.database.collection(self.collection_name)
        col.find("root_object_id" => root_object.id, "parent_configuration_id" => nil).each do |config|
          config["configurations"] = get_children_for(col, config["_id"])
          configs << config
        end
        configs
      end

      def get_children_for(col, parent_configuration_id)
        documents = []
        col.find("parent_configuration_id" => parent_configuration_id).each do |doc|
          doc["configurations"] = get_children_for(col, doc["_id"])
          documents << doc
        end
        documents
      end



      def get_renderable_hash_by_root_object(root_object)
        configs = []
        col = Mongoid.database.collection(self.collection_name)
        col.find("root_object_id" => root_object.id, "parent_configuration_id" => nil, "renderable" => true).each do |config|
          config["configurations"] = get_renderable_children_for(col, config["_id"])
          configs << config
        end
        configs
      end

      def get_renderable_children_for(col, parent_configuration_id)
        documents = []
        col.find("parent_configuration_id" => parent_configuration_id, "renderable" => true).each do |doc|
          doc["configurations"] = get_renderable_children_for(col, doc["_id"])
          documents << doc
        end
        documents
      end


      def renderable_hash_for_configuration(configuration_id)
        col = Mongoid.database.collection(self.collection_name)
        config = col.find("_id" => configuration_id).first
        config["configurations"] = get_renderable_children_for(col, config["_id"])
        config
      end

    end
  end
end