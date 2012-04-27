module ActiveWorker
  class Configuration
    include Mongoid::Document
    include Behavior::HasRootObject

    has_many :events, :class_name => "ActiveWorker::Event"

    has_many   :configurations,
               :as => :parent_configuration,
               :class_name => 'ActiveWorker::Configuration',
               :autosave => true

    belongs_to :parent_configuration,
               :polymorphic => true

    alias_method :root_owner, :parent_configuration

    field :polling_interval, :type => Integer, :default => 1

    field :renderable, :type => Boolean, :default => false

    scope :mine, ->(parent_config) {where(parent_configuration_id: parent_config.id )}

    def launch
      self.class.controller_class.run_remotely.launch_thread(self.id)
    end

    def supported_child_configurations
      []
    end

    def self.controller_class
      "#{self.parent}::Controller".constantize
    end

    def self.display_name
      name.split("::").join(" ")
    end

    def self.css_name
      name.split("::").join("_")
    end

    def renderable_configurations
      configurations.select {|c| c.renderable}
    end

    def generate_message
      "This is the base finished event message."
    end

    def completed?
      FinishedEvent.where(configuration_id: id).count > 0
    end

    def finished
      FinishedEvent.create(configuration: self)
    end

    def self.get_as_hash_by_root_object(root_object)
      configs = []
      col = Mongoid.database.collection(self.collection_name)
      col.find("root_object_id" => root_object.id, "parent_configuration_id" => nil).each do |config|
        config["configurations"] = get_children_for(col, config["_id"])
        configs << config
      end
      configs
    end

    def self.get_children_for(col, parent_configuration_id)
      documents = []
      col.find("parent_configuration_id" => parent_configuration_id).each do |doc|
        doc["configurations"] = get_children_for(col, doc["_id"])
        documents << doc
      end
      documents
    end

    def self.get_renderable_hash_by_root_object(root_object)
      configs = []
      col = Mongoid.database.collection(self.collection_name)
      col.find("root_object_id" => root_object.id, "parent_configuration_id" => nil, "renderable" => true).each do |config|
        config["configurations"] = get_renderable_children_for(col, config["_id"])
        configs << config
      end
      configs
    end

    def self.get_renderable_children_for(col, parent_configuration_id)
      documents = []
      col.find("parent_configuration_id" => parent_configuration_id, "renderable" => true).each do |doc|
        doc["configurations"] = get_children_for(col, doc["_id"])
        documents << doc
      end
      documents
    end



  end
end
