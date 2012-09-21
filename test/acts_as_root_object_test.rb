require_relative "test_helper"

module ActiveWorker
  class ActsAsRootObjectTest < ActiveSupport::TestCase


    test "renderable configuration hashes returns array of configuration hashes" do
      root = Rootable.create
      topconfig1 = root.configurations.create({}, TemplatableTopConfig)
      topconfig2 = root.configurations.create({}, TemplatableTopConfig)
      child_config1 = topconfig2.configurations.create({}, TemplatableChildConfig)

      assert_equal 2, root.renderable_configuration_hashes.size
      assert_equal 1, root.renderable_configuration_hashes[1]["configurations"].size

    end

    test "renderable configurations hashes only returns with renderable configurations" do

      root = Rootable.create

      topconfig1 = root.configurations.create({}, TemplatableTopConfig)
      topconfig2 = root.configurations.create({}, TopConfig)
      templatable_child_config1 = topconfig1.configurations.create({}, TemplatableChildConfig)
      child_config1 = topconfig1.configurations.create({}, ChildConfig)

      templatable_child_config2 = topconfig2.configurations.create({}, TemplatableChildConfig)
      child_config2 = topconfig2.configurations.create({}, ChildConfig)

      renderable_hashes = root.renderable_configuration_hashes

      assert_equal 1, renderable_hashes.size
      assert_equal 1, renderable_hashes[0]["configurations"].size

    end

    test "sets flags on immediate child configurations" do
      root = Rootable.create flags: {"flag" => true}

      topconfig1 = root.configurations.create({}, TemplatableTopConfig)
      topconfig2 = root.configurations.create({}, TopConfig)
      root.set_flags
      topconfig1.reload
      topconfig2.reload

      templatable_child_config1 = topconfig1.configurations.create({}, TemplatableChildConfig)
      child_config1 = topconfig1.configurations.create({}, ChildConfig)

      templatable_child_config2 = topconfig2.configurations.create({}, TemplatableChildConfig)
      child_config2 = topconfig2.configurations.create({}, ChildConfig)

      assert topconfig1.flags["flag"]
      assert topconfig2.flags["flag"]
      assert templatable_child_config1.flags["flag"]
      assert child_config1.flags["flag"]
      assert templatable_child_config2.flags["flag"]
      assert child_config2.flags["flag"]
    end

    test "is completed when configurations complete" do
      root = Rootable.create
      topconfig1 = root.configurations.create({}, TemplatableTopConfig)
      topconfig2 = root.configurations.create({}, TemplatableTopConfig)

      root.reload
      assert_equal false, root.completed?

      topconfig1.finished

      root.reload
      assert_equal false, root.completed?

      topconfig2.finished

      root.reload
      assert_equal true, root.completed?

    end

    test "duration calculates when completed" do
      root = Rootable.create
      topconfig1 = root.configurations.create({}, TemplatableTopConfig)

      initial_duration = root.duration

      assert initial_duration > 0

      topconfig1.finished

      final_duration = root.duration

      assert initial_duration < final_duration
    end

    test "duration returns 0 if completed but missing finished_at" do
      root = Rootable.create

      root.root_object_finished = true

      duration = root.duration

      assert_equal 0, duration
    end


    test "sets finished_at correctly" do
      root = Rootable.create
      topconfig1 = root.configurations.create({}, TemplatableTopConfig)

      assert_nil root.finished_at

      topconfig1.finished
      assert root.finished_at.to_i > 0
    end

  end

end