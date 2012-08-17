module ActiveWorker
  class Template
    include Mongoid::Document

    has_and_belongs_to_many :child_templates,  :class_name => "ActiveWorker::Template", :inverse_of => :parent_templates
    has_and_belongs_to_many :parent_templates, :class_name => "ActiveWorker::Template", :inverse_of => :child_templates

    field :name
    field :configuration_type

    scope :with_names, where(:name.exists => true)

    def name_from_class
      self.class.to_s.split("::")[0..-2].join(" ")
    end

    def build_configuration
      configuration = configuration_class.new

      configuration_class.template_fields.each do |field|
        configuration.write_attribute(field,read_attribute(field))
      end

      configuration.template_name = name

      child_template_ids.each do |child_id|
        child = Template.find(child_id)
        configuration.configurations << child.build_configuration
      end

      configuration
    end

    def configuration_class
      configuration_type.constantize
    end
  end
end