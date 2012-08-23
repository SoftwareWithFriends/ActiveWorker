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

      child_config = ChildConfig.where(parent_configuration_id: parent_config.to_param).first
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

    test "passes down flags when saved" do
      root = Rootable.create flags: {"analyze_performance" => true}
      config = TopConfig.new root_object: root, flags: root.flags
      config2 = ChildConfig.new parent_configuration: config

      config.save!
      config2.save!
      assert config2.flags["analyze_performance"]
    end

    test "can get configuration hierarchy" do
      root = Rootable.create
      config = TopConfig.create root_object: root
      config2 = ChildConfig.create parent_configuration: config
      config3 = ChildConfig.create parent_configuration: config
      config4 = ChildConfig.create parent_configuration: config3
      config5 = ChildConfig.create parent_configuration: config3

      top_config = Configuration.get_as_hash_by_root_object(root).first

      assert_equal config.to_param, top_config["_id"]
      assert_equal config2.to_param, top_config["configurations"][0]["_id"]
      assert_equal config3.to_param, top_config["configurations"][1]["_id"]

      assert_equal config4.to_param, top_config["configurations"][1]["configurations"][0]["_id"]
      assert_equal config5.to_param, top_config["configurations"][1]["configurations"][1]["_id"]
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
      assert_equal config.to_param, top_config["_id"]
      assert_equal 1, top_config["configurations"].size
      assert_equal config2.to_param, top_config["configurations"][0]["_id"]

      assert_equal config6.to_param, top_config["configurations"][0]["configurations"][0]["_id"]
      assert_equal 1, top_config["configurations"][0]["configurations"].size
      assert_equal config8.to_param, top_config["configurations"][0]["configurations"][0]["configurations"][0]["_id"]
    end

    test "can get renderable hash for given configuration" do
      config = TopConfig.create renderable: true
      config2 = ChildConfig.create parent_configuration: config, renderable: true
      config3 = ChildConfig.create parent_configuration: config, renderable: false

      top_config = Configuration.renderable_hash_for_configuration(config.id)

      assert_equal config.to_param, top_config["_id"]
      assert_equal 1, top_config["configurations"].size
      assert_equal config2.to_param, top_config["configurations"][0]["_id"]
      assert_equal "ActiveWorker::TopConfig", top_config["_type"]
    end

    test "Base Configurations can be hashable with type" do
      config = Configuration.create renderable: true
      config2 = Configuration.create parent_configuration: config, renderable: true
      config3 = Configuration.create parent_configuration: config, renderable: false

      top_config = Configuration.renderable_hash_for_configuration(config.id)

      assert_equal config.to_param.to_s, top_config["_id"]
      assert_equal 1, top_config["configurations"].size
      assert_equal config2.to_param.to_s, top_config["configurations"][0]["_id"]

      assert_equal "ActiveWorkerConfiguration", top_config["_type"]
      assert_equal "ActiveWorkerConfiguration", top_config["configurations"][0]["_type"]

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
      id1 = config.to_param
      id2 = config2.to_param

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
      assert_equal 1, StartedEvent.where(configuration_id: configuration.to_param).size
      assert_match /#{configuration.event_name}/, StartedEvent.where(configuration_id: configuration.to_param).first.message
    end

    test "can create finished event" do
      configuration = Configuration.create

      configuration.finished
      assert_equal 1, FinishedEvent.where(configuration_id: configuration.to_param).size
      assert_match /#{configuration.event_name}/, FinishedEvent.where(configuration_id: configuration.to_param).first.message
    end

    test "can be notified" do
      configuration = Configuration.create
      assert_equal false, configuration.notified?
      configuration.notify
      assert configuration.notified?
    end

    test "can treat as hash" do
      config = Configuration.create value: "value"

      assert_equal "value", config[:value]

      config[:value]= "value2"

      assert_equal "value2", config[:value]

      assert_nil config[:bad_method]

    end

    test "can retrieve hash of expandable fields" do
      class TestConfig < Configuration
        config_field :config_field
        template_field :template_field
        field :other_field
      end

      config = TestConfig.create config_field: "config_field",
                                 template_field: "template_field",
                                 other_field: "other_field"

      expected_expandable_fields = {"config_field" => "config_field",
                                    "template_field" => "template_field"}
      assert_equal expected_expandable_fields, config.expandable_fields
    end


  end
end
