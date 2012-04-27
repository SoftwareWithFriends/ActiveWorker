require_relative "test_helper"

module ActiveWorker
  class ControllerTest < ActiveSupport::TestCase

    test "can create started event" do
      configuration = Configuration.create
      controller = Controller.new(configuration)
      controller.started
      assert_equal 1, StartedEvent.where(configuration_id: configuration.id).size
    end

    test "creates started event during launch_thread" do

      configuration = Configuration.create

      Controller.any_instance.stubs(:execute)
      Controller.launch_thread(configuration.id)

      assert_equal 1, StartedEvent.where(configuration_id: configuration.id).size

    end

    test "creates finished event during launch_thread" do

      configuration = Configuration.create

      Controller.any_instance.stubs(:execute)
      Controller.launch_thread(configuration.id)

      assert_equal 1, FinishedEvent.where(configuration_id: configuration.id).size

    end
  end
end