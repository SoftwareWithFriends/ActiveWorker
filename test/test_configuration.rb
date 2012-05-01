require_relative "test_helper"

module ActiveWorker
  class ConfigurationTest < ActiveSupport::TestCase



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

    test "can get configuration hierarchy" do
      root = Rootable.create
      config = TopConfig.create root_object: root
      config2 = ChildConfig.create parent_configuration: config
      config3 = ChildConfig.create parent_configuration: config
      config4 = ChildConfig.create parent_configuration: config3
      config5 = ChildConfig.create parent_configuration: config3

      top_config = Configuration.get_as_hash_by_root_object(root).first

      assert_equal config.id, top_config["_id"]
      assert_equal config2.id, top_config["configurations"][0]["_id"]
      assert_equal config3.id, top_config["configurations"][1]["_id"]

      assert_equal config4.id, top_config["configurations"][1]["configurations"][0]["_id"]
      assert_equal config5.id, top_config["configurations"][1]["configurations"][1]["_id"]
    end

    test "can get renderable configuration hierarchy" do
      root = Rootable.create
      config = TopConfig.create root_object: root, renderable: true
      config2 = ChildConfig.create parent_configuration: config, renderable: true
      config3 = ChildConfig.create parent_configuration: config, renderable: false
      config4 = ChildConfig.create parent_configuration: config3, renderable: true
      config5 = ChildConfig.create parent_configuration: config3, renderable: false
      config6 = ChildConfig.create parent_configuration: config2, renderable: true
      config7 = ChildConfig.create parent_configuration: config6, renderable: false
      config8 = ChildConfig.create parent_configuration: config6, renderable: true

      top_config = Configuration.get_renderable_hash_by_root_object(root).first
      assert_equal config.id, top_config["_id"]
      assert_equal 1, top_config["configurations"].size
      assert_equal config2.id, top_config["configurations"][0]["_id"]

      assert_equal config6.id, top_config["configurations"][0]["configurations"][0]["_id"]
      assert_equal 1, top_config["configurations"][0]["configurations"].size
      assert_equal config8.id, top_config["configurations"][0]["configurations"][0]["configurations"][0]["_id"]
    end

    test "can get renderable hash for given configuration" do
      config = TopConfig.create renderable: true
      config2 = ChildConfig.create parent_configuration: config, renderable: true
      config3 = ChildConfig.create parent_configuration: config, renderable: false

      top_config = Configuration.renderable_hash_for_configuration(config.id)

      assert_equal config.id, top_config["_id"]
      assert_equal 1, top_config["configurations"].size
      assert_equal config2.id, top_config["configurations"][0]["_id"]
    end

    test "can load hashes from configurations that no longer exist" do
      module SoonToNotExist
        class TopConfig < Configuration
          field :top_field

          def child_configs
            ChildConfig.mine(self).all
          end
        end

        class ChildConfig < Configuration
          field :child_field
        end
      end
      root = Rootable.create
      config = SoonToNotExist::TopConfig.create root_object: root
      config2 = SoonToNotExist::ChildConfig.create parent_configuration: config
      id1 = config.id
      id2 = config2.id

      ActiveWorker::ConfigurationTest::SoonToNotExist.send(:remove_const, :TopConfig)
      ActiveWorker::ConfigurationTest::SoonToNotExist.send(:remove_const, :ChildConfig)

      assert_raise NameError do
        SoonToNotExist::TopConfig
      end
      assert_raise NameError do
        SoonToNotExist::ChildConfig
      end

      top_config = Configuration.get_as_hash_by_root_object(root).first
      assert_equal id1, top_config["_id"]
      assert_equal id2, top_config["configurations"][0]["_id"]

    end

    test "can create started event" do
      configuration = Configuration.create

      configuration.started
      assert_equal 1, StartedEvent.where(configuration_id: configuration.id).size
      assert_match /#{configuration.event_name}/,StartedEvent.where(configuration_id: configuration.id).first.message
    end

    test "can create finished event" do
      configuration = Configuration.create

      configuration.finished
      assert_equal 1, FinishedEvent.where(configuration_id: configuration.id).size
      assert_match /#{configuration.event_name}/,FinishedEvent.where(configuration_id: configuration.id).first.message
    end

  end
end
