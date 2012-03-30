require_relative "behavior/has_root_object"
module ActiveWorker
  class Event
    include Mongoid::Document
    include Mongoid::Timestamps
    include Behavior::HasRootObject

    belongs_to :configuration, :class_name => "ActiveWorker::Configuration"
    alias_method :root_owner, :configuration

    before_save :set_message, :set_host_information

    validates_presence_of :configuration, :message => "Events must be owned by a Configuration"

    field :message, :type => String
    field :host, :type => String


    scope :for_root_object_id, lambda {|root_object_id| where(:root_object_id => root_object_id).descending(:created_at)}

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

    def set_host_information
      self.host = HostInformation.hostname
    end

    def set_message
      return if message
      self.message = configuration.generate_message
    end

    def generate_message
      nil
    end

  end
end
