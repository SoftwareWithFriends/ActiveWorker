require_relative "test_helper"

module ActiveWorker
  class FinishedEventTest < ActiveSupport::TestCase

    test "exists_for_configurations scopes to finished events" do
      config1 = Configuration.create
      config2 = Configuration.create
      config3 = Configuration.create

      FinishedEvent.create configuration: config1
      FinishedEvent.create configuration: config2

      configs = [config1, config2, config3]

      assert_equal false, FinishedEvent.exists_for_configurations?(configs)

      Event.create configuration: config3

      assert_equal false, FinishedEvent.exists_for_configurations?(configs)

      FinishedEvent.create configuration: config3

      assert FinishedEvent.exists_for_configurations?(configs)
    end

    test "finished message" do
      configuration = Configuration.create
      event = FinishedEvent.create(configuration: configuration)

      assert_match /finished/, event.message
    end

  end
end
