require_relative "test_helper"

module ActiveWorker
  class ExpandableTest < ActiveSupport::TestCase



    test "can expand configuration for workers" do
      root_object = Rootable.create
      parent_config = TopConfig.create(root_object_id: root_object.id)

      config = ExpandableConfig.create(
          name: "First",
          size: 0,
          parent_configuration: parent_config,
          foo: "bar",
          root_object_id: parent_config.root_object_id,
          number_of_workers: 4,
          number_of_threads: 5,
      )

      defined_fields = config.defined_fields.dup

      expanded_configs = config.expand_for_workers

      expected_number_of_configs = 4
      assert_expanded_configs(config, defined_fields, expanded_configs, expected_number_of_configs, parent_config, root_object)
    end

    test "can expand configuration for threads" do
      root_object = Rootable.create
      parent_config = TopConfig.create(root_object_id: root_object.id)

      config = ExpandableConfig.create(
          name: "First",
          size: 0,
          parent_configuration: parent_config,
          foo: "bar",
          root_object_id: parent_config.root_object_id,
          number_of_workers: 4,
          number_of_threads: 5,
      )

      defined_fields = config.defined_fields.dup

      expanded_configs = config.expand_for_threads

      expected_number_of_configs = 5
      assert_expanded_configs(config, defined_fields, expanded_configs, expected_number_of_configs, parent_config, root_object)
    end

    test "can expand threads using maps" do
      root_object = Rootable.create
      parent_config = TopConfig.create(root_object_id: root_object.id)

      config = MappedExpandableConfig.create(
          name: "First",
          size: 0,
          parent_configuration: parent_config,
          foo: "bar",
          root_object_id: parent_config.root_object_id,
          number_of_workers: 4,
          number_of_threads: 5,
      )
      expected_number_of_configs = 5
      expanded_configs = config.expand_for_threads

      assert_equal expected_number_of_configs, expanded_configs.size
      assert_equal [0,1,2,3,4], expanded_configs.map(&:size)
      assert_nil expanded_configs.first.thread_root_configuration_id
      expanded_configs[1..-1].each do |threaded_config|
        assert_equal expanded_configs.first, threaded_config.thread_root_configuration
      end
    end

    test "can expand workers using maps" do
      root_object = Rootable.create
      parent_config = TopConfig.create(root_object_id: root_object.id)

      config = MappedExpandableConfig.create(
          name: "First",
          size: 0,
          parent_configuration: parent_config,
          foo: "bar",
          root_object_id: parent_config.root_object_id,
          number_of_workers: 4,
          number_of_threads: 5,
      )
      expected_number_of_configs = 4
      expanded_configs = config.expand_for_workers

      assert_equal expected_number_of_configs, expanded_configs.size
      assert_equal [0,1,2,3], expanded_configs.map(&:size)
    end

    def assert_expanded_configs(config, defined_fields, expanded_configs, expected_number_of_configs, parent_config, root_object)
      assert_equal expected_number_of_configs, expanded_configs.size

      expanded_configs.each do |expanded_config|
        assert_equal parent_config, expanded_config.parent_configuration
        assert_equal root_object.id, expanded_config.root_object_id
        assert_equal defined_fields, expanded_config.defined_fields
      end

      expanded_configs.each do |expanded_config|
        next if expanded_config == config
        assert_nil expanded_config.foo
        assert_equal false, expanded_config.renderable
      end
    end

  end
end