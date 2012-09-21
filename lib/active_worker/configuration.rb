module ActiveWorker
  class Configuration
    include Mongoid::Document
    include Behavior::HasRootObject
    extend Behavior::Hashable
    POLLING_INTERVAL = 0.1

    has_many :events, :class_name => "ActiveWorker::Event"

    has_many :configurations,
             :as => :parent_configuration,
             :class_name => 'ActiveWorker::Configuration',
             :autosave => true

    belongs_to :parent_configuration,
               :polymorphic => true

    alias_method :root_owner, :parent_configuration
    root_object_relation :configurations

    field :polling_interval, :type => Integer, :default => 1
    field :renderable, :type => Boolean, :default => false
    field :flags, type: Hash, default: {}

    before_save :set_flags

    scope :mine, ->(parent_config) { where(parent_configuration_id: parent_config.id) }

    def launch
      configurations = expand_for_workers
      configurations.each(&:enqueue_job)
      configurations += collect_after_launch_configurations(configurations)
      configurations
    end

    def collect_after_launch_configurations(configurations)
      self.class.after_launch_methods.map { |method| send(method, configurations) }.flatten
    end

    def expand_for_workers
      [self]
    end

    def expand_for_threads
      [self]
    end

    def configurations_for_events
      [self]
    end

    def enqueue_job
      self.class.controller_class.run_remotely.execute_worker(self.id)
      self
    end

    def supported_child_configurations
      []
    end

    def defined_fields
      attributes.select { |k, v| self.class.config_fields.include? k.to_sym }
    end

    def event_name
      parts = self.class.name.split("::")
      parts.pop
      parts.join(" ")
    end

    def renderable_configurations
      configurations.select { |c| c.renderable }
    end

    def completed?
      FinishedEvent.where(configuration_id: id).count > 0
    end

    def wait_until_completed
      sleep(POLLING_INTERVAL) until completed?
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

    def self.controller_class
      "#{self.parent}::Controller".constantize
    end

    def self.display_name
      name.split("::").join(" ")
    end

    def self.css_name
      name.split("::").join("_")
    end

    def self.template_field(name, *args)
      config_field(name, *args)
      template_fields << name
    end

    def self.config_field(name, *args)
      field name, *args
      config_fields << name
    end

    def self.template_fields
      @template_fields ||= []
    end

    def self.config_fields
      @config_fields ||= []
    end

    def self.after_launch(method)
      after_launch_methods << method
    end

    def self.after_launch_methods
      @after_launch_methods ||= []
    end

  end
end
