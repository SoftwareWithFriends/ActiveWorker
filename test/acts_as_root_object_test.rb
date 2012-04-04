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

  end
end