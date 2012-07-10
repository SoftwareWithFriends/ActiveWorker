module ActiveWorker
  class Configuration
    include Mongoid::Document
    include Behavior::HasRootObject
    extend  Behavior::Hashable

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
    field :flags, type: Hash, default: {}

    before_save :set_flags

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

    def event_name
      parts = self.class.name.split("::")
      parts.pop
      parts.join(" ")
    end

    def renderable_configurations
      configurations.select {|c| c.renderable}
    end

    def completed?
      FinishedEvent.where(configuration_id: id).count > 0
    end

    def started
      StartedEvent.create(configuration: self)
    end

    def finished
      FinishedEvent.create(configuration: self)
    end

    def notify
      NotificationEvent.create(configuration: self)
    end

    def notified?
      NotificationEvent.where(configuration_id: id).count > 0
    end

    def set_flags
      self.flags = parent_configuration.flags if parent_configuration
      true
    end

  end
end
