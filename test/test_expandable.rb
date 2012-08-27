require_relative "test_helper"

module ActiveWorker
  class ExpandableTest < ActiveSupport::TestCase

    class ExpandableConfig < Configuration
      include Expandable
      field :foo
      template_field :name
      config_field :size
    end

    test "can expand configuration" do
      root_object = Rootable.create
      parent_config = TopConfig.create(root_object_id: root_object.id)

      config = ExpandableConfig.create(
          name: "First",
          size: 0,
          parent_configuration: parent_config,
          foo: "bar",
          root_object_id: parent_config.root_object_id
      )

      defined_fields = config.defined_fields.dup

      additional_configurations = 4
      expected_total_configurations = 5

      expanded_configs = config.expand_configuration(additional_configurations)
      assert_equal expected_total_configurations, expanded_configs.size

      expanded_configs.each do |expanded_config|
        assert_equal parent_config, expanded_config.parent_configuration
        assert_equal root_object.id, expanded_config.root_object_id
        assert_equal defined_fields, expanded_config.defined_fields
      end

      expanded_configs.each do |expanded_config|
        next if expanded_config == config
        assert_nil expanded_config.foo
      end

    end

    test "expands correct number of workers" do
      config = ExpandableConfig.create number_of_workers: 5
      config.expects(:expand_configuration).with(4)
      config.expand_for_workers
    end

    test "expands correct number of threads" do
      config = ExpandableConfig.create number_of_threads: 5
      config.expects(:expand_configuration).with(4)
      config.expand_for_threads
    end

  end
end