module ActiveWorker
  module Templatable


    def self.included(base)
      base.field :renderable, :type => Boolean, :default => true
    end

    def find_template
      child_template_ids = configurations.map(&:find_template).map(&:id)

      attributes_for_template = {}
      if child_template_ids.any?
        attributes_for_template[:child_template_ids] = child_template_ids
      end

      template_class.fields_for_configuration.each do |field|
        attributes_for_template[field] = self.send(field)
      end

      template = template_class.find_or_create_by(attributes_for_template)
      template
    end

    def template_class
      templated_class_name = "#{self.class.parent}::Template"
      templated_class = templated_class_name.constantize
      templated_class
    end
  end


end
