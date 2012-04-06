module ActiveWorker
  class Template
    include Mongoid::Document

    has_and_belongs_to_many :child_templates,  :class_name => "ActiveWorker::Template", :inverse_of => :parent_templates
    has_and_belongs_to_many :parent_templates, :class_name => "ActiveWorker::Template", :inverse_of => :child_templates

    field :name, :type => String

    def name_from_class
      self.class.to_s.split("::")[0..-2].join(" ")
    end

    def build_configuration
      configuration = self.class.configuration_class.new

      self.class.fields_for_configuration.each do |field|
        configuration.send("#{field}=",self.send(field))
      end

      child_template_ids.each do |child_id|
        child = Template.find(child_id)
        configuration.configurations << child.build_configuration
      end

      configuration
    end

    def self.field_for_configuration(name, *args)
      field name, *args
      fields_for_configuration << name
    end

    def self.fields_for_configuration
      @fields ||= []
    end

    def self.configuration_class
      "#{self.parent}::Configuration".constantize
    end
  end
end