require_relative "test_helper"

module ActiveWorker
  class TestTemplate < ActiveSupport::TestCase

    test "can find all with name" do
      Template.create(configuration_type: Configuration.name)
      Template.create name: "template", configuration_type: Configuration.name

      assert_equal 1, ActiveWorker::Template.with_names(Configuration).count
    end

    test "can create nested templates" do
      top_temp = Template.create(configuration_type: Configuration.name)

      child_template = Template.create(configuration_type: Configuration.name, foo: "Bar")


      top_temp.child_templates << child_template
      top_temp.child_templates << child_template

      assert_equal 1, top_temp.child_templates.count, "Mongoid No Longer De-Dupes Relationships"
      assert_equal 1, top_temp.child_template_ids.count

    end

  end

end