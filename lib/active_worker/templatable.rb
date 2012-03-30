module ActiveWorker
  module Templatable

    def find_template
      child_template_ids = configurations.map(&:find_template).map(&:id)

      attributes_for_template = {}
      if child_template_ids.any?
        attributes_for_template[:child_template_ids] = child_template_ids
      end

      template_class.fields_for_configuration.each do |field|
        attributes_for_template[field] = self.send(field)
      end

      template_class.find_or_create_by(attributes_for_template)
    end

    def template_class
      "#{self.class.parent}::Template".constantize
    end

    def renderable?
      true
    end

  end
end