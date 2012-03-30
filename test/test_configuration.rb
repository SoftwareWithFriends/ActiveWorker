require_relative "test_helper"

module ActiveWorker
  class ConfigurationTest < ActiveSupport::TestCase

    class Rootable
      include Mongoid::Document
      include ActiveWorker::Behavior::ActsAsRootObject
    end


    class TopConfig < Configuration
      field :top_field

      def child_configs
        ChildConfig.mine(self).all
      end
    end

    class ChildConfig < Configuration
      field :child_field
    end

    test "can scope a child configuration type using mine" do
      parent_config = TopConfig.create(top_field: "top field")
      child_config0 = ChildConfig.create(child_field: "child field", parent_configuration: parent_config)
      child_config1 = ChildConfig.create(child_field: "different child field")

      assert_equal 1, parent_config.child_configs.count
      assert_equal child_config0, parent_config.child_configs.first

    end

    test "Child Config is of the correct type" do
    parent_config = TopConfig.create(top_field: "top field")
    child_config0 = ChildConfig.create(child_field: "child field", parent_configuration: parent_config)

    assert_equal TopConfig, parent_config.class

    child_config = ChildConfig.where(parent_configuration_id: parent_config.id).first
    assert_equal ChildConfig, child_config.class

    end

    test "completed?" do
      config = TopConfig.create
      assert_equal false, config.completed?
      FinishedEvent.create configuration: config
      assert config.completed?
    end

    test "passses down root object when saved" do
      root = Rootable.create
      config = TopConfig.new root_object: root
      config2 = ChildConfig.new parent_configuration: config

      config.save!
      config2.save!
      assert_equal root, config2.root_object
    end

  end
end
