module ActiveWorker
  module Templatable

    module ClassMethods
      def templates_with_names
        Template.with_names(self)
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
      template.name = template_name if template_name && (! template_name.empty?)
      template.save!
      template
    end

    def template_name_or(input_string)
      if template_name && (! template_name.empty?)
        template_name
      else
        input_string
      end
    end

  end
end
