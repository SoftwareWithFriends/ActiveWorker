require_relative "behavior/has_root_object"
module ActiveWorker
  class Event
    include Mongoid::Document
    include Mongoid::Timestamps
    include Behavior::HasRootObject

    belongs_to :configuration, :class_name => "ActiveWorker::Configuration"
    alias_method :root_owner, :configuration
    root_object_relation :events

    index({:configuration_id => -1, :_type => 1}, {:background => true})

    before_save :set_message, :set_process_information

    validates_presence_of :configuration, :message => "Events must be owned by a Configuration"

    field :message, :type => String
    field :host, :type => String
    field :process_id, :type => Integer
    field :worker_pid, :type => Integer

    scope :for_root_object_id, lambda {|root_object_id| where(:root_object_id => root_object_id).descending(:created_at)}


    def self.exists_for_configurations?(configurations)
      where(:configuration_id.in => configurations.map(&:id)).count == configurations.size
    end

    def fields_for_view
      view_fields = {}
      fields.keys.each do |field|
        view_fields[field] = self.send(field)
      end
      view_fields
    end

    def event_type
      self.class.name.split('::').last.underscore
    end

    def set_process_information
      self.host = HostInformation.hostname
      self.process_id = get_pid
      self.worker_pid = get_worker_pid
    end

    def get_pid
      Process.pid.to_i
    end

    def get_worker_pid
      worker = JobQueue::QueueManager.new.active_jobs_for_configurations([configuration.to_param]).first
      return worker["pid"] if worker
      nil
    end

    def set_message
      return if message
      self.message = generate_message
    end

    def generate_message
      "#{configuration.event_name} base message"
    end

  end
end
