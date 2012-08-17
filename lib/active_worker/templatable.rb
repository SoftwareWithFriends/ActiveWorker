module ActiveWorker
  module Templatable

    module ClassMethods
      def template_class
        templated_class_name = "#{parent}::Template"
        templated_class = templated_class_name.constantize
        templated_class
      end
    end


    def self.included(base)
      base.field :renderable, :type => Boolean, :default => true
      base.field :template_name

      base.extend(ClassMethods)
    end

    def find_template
      child_template_ids = configurations.map(&:find_template).map(&:id)

      attributes_for_template = {}
      attributes_for_template[:configuration_type] = self.class.name

      if child_template_ids.any?
        attributes_for_template[:child_template_ids] = child_template_ids
      end

      self.class.template_fields.each do |field|
        attributes_for_template[field] = read_attribute(field)
      end

      template = Template.find_or_create_by(attributes_for_template)
      template.name = template_name if template_name && (not template_name.empty?)
      template.save!
      template
    end

  end


end
