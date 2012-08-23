require_relative "test_helper"

module ActiveWorker
  class IntegrationTest < ActiveSupport::TestCase

    test "can create correct templates" do

      parent_config = TemplatableTopConfig.create(top_field: "top field", other_top_field: "other top field")
      child_config0 = TemplatableChildConfig.create(child_field: "child field", other_child_field: "other child field", parent_configuration: parent_config)
      child_config1 = TemplatableChildConfig.create(child_field: "different child field",other_child_field: "different other child field", parent_configuration: parent_config)

      top_template = parent_config.find_template

      assert_kind_of Template, top_template
      assert_equal TemplatableTopConfig.name, top_template.configuration_type
      assert_equal 2, top_template.child_templates.count

      assert_equal parent_config.top_field,top_template[:top_field]
      assert_nil top_template[:other_top_field]

      child_template0 = top_template.child_templates[0]
      child_template1 = top_template.child_templates[1]

      assert_equal child_config0.child_field, child_template0[:child_field]
      assert_equal child_config1.child_field, child_template1[:child_field]

      assert_equal TemplatableChildConfig.name, child_template0.configuration_type
      assert_equal TemplatableChildConfig.name, child_template0.configuration_type

    end

    test "can recreate correct configurations from templates" do
      parent_config = TemplatableTopConfig.create(top_field: "top field", other_top_field: "other top field")
      child_config0 = TemplatableChildConfig.create(child_field: "child field", other_child_field: "other child field", parent_configuration: parent_config)
      child_config1 = TemplatableChildConfig.create(child_field: "different child field",other_child_field: "different other child field", parent_configuration: parent_config)

      top_template = parent_config.find_template

      created_config = top_template.build_configuration

      assert_kind_of TemplatableTopConfig, created_config
      assert_equal parent_config.top_field, created_config.top_field
      assert_nil created_config.other_top_field

      created_child_config0 = created_config.configurations[0]
      created_child_config1 = created_config.configurations[1]

      assert_equal child_config0.child_field, created_child_config0.child_field
      assert_equal child_config1.child_field, created_child_config1.child_field

      assert_nil created_child_config0.other_child_field
      assert_nil created_child_config1.other_child_field
    end

  end
end