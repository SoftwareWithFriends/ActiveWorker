require_relative "test_helper"

module ActiveWorker
  class ActsAsRootObjectTest < ActiveSupport::TestCase
    test "completed? true if no configurations" do

      root = Rootable.create
      assert root.completed?
    end

    test "completed? false if any configurations are not completed" do
      root = Rootable.create
      root.configurations.create

      assert_equal false, root.completed?
    end

    test "completed? stays true once true" do
      root = Rootable.create
      assert root.completed?

      root.configurations.create

      assert root.completed?
    end

    test "completed? once true never loads immediate child configurations" do
      root = Rootable.create
      assert root.completed?

      root.configurations.create

      root.expects(:immediate_child_configurations).never

      assert root.completed?
    end

    test "renderable configuration hases returns array of configuration hashess" do
      root = Rootable.create
      topconfig1 = root.configurations.create({},TemplatableTopConfig)
      topconfig2 = root.configurations.create({},TemplatableTopConfig)
      child_config1 = topconfig2.configurations.create({},TemplatableChildConfig)

      assert_equal 2, root.renderable_configuration_hashes.size
      assert_equal 1, root.renderable_configuration_hashes[1]["configurations"].size

    end

    test "renderable configurations hashes only returns with renderable configurations" do

      root = Rootable.create

      topconfig1 = root.configurations.create({},TemplatableTopConfig)
      topconfig2 = root.configurations.create({},TopConfig)
      templatable_child_config1 = topconfig1.configurations.create({},TemplatableChildConfig)
      child_config1 = topconfig1.configurations.create({},ChildConfig)

      templatable_child_config2 = topconfig2.configurations.create({},TemplatableChildConfig)
      child_config2 = topconfig2.configurations.create({},ChildConfig)

      renderable_hashes = root.renderable_configuration_hashes

      assert_equal 1, renderable_hashes.size
      assert_equal 1, renderable_hashes[0]["configurations"].size

    end

  end
end