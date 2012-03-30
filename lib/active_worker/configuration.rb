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

    def renderable?
      false
    end

    def renderable_configurations
      configurations.select {|c| c.renderable?}
    end

    def generate_message
      "This is the base finished event message."
    end

    def completed?
      FinishedEvent.where(configuration_id: id).count > 0
    end

  end
end
