require_relative "test_helper"

module ActiveWorker
  class TemplatableTest < ActiveSupport::TestCase

    test "can get input string with empty template_name" do
      config = TemplatableTopConfig.create template_name: ""
      string = "New Name"

      assert_not_nil config.template_name
      assert_equal "", config.template_name
      assert_equal string, config.template_name_or(string)
    end

    test "can get template_name" do
      config = TemplatableTopConfig.create template_name: "Template Name"
      string = "New Name"

      assert_equal "Template Name", config.template_name_or(string)
    end

    test "can have duplicate child template" do
      top_config = TemplatableTopConfig.create template_name: "top", top_field: "top_field"
      child_config1 = TemplatableChildConfig.create child_field: "same", parent_configuration: top_config
      child_config2 = TemplatableChildConfig.create child_field: "same", parent_configuration: top_config

      assert_equal 2, top_config.configurations.count

      template = top_config.find_template

      assert_equal "top_field", template.top_field

      assert_equal 2, template.child_template_ids.size
      assert_equal 2, template.child_template_ids.count

      assert_equal 1, template.child_templates.size


      # Makes new Configurations, does not put them in the database
      new_config = template.build_configuration
      assert_equal 2, new_config.configurations.size
    end

  end
end