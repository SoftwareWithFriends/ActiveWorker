require_relative "test_helper"

module ActiveWorker
  class StartedEventTest < ActiveSupport::TestCase

    test "can create started event on a configuration" do
      configuration = Configuration.create

      event = StartedEvent.create(configuration: configuration)
      found_events = StartedEvent.where(configuration_id: configuration.id)

      assert_equal 1, found_events.size
      assert_equal event, found_events.first
    end

    test "started message" do
      configuration = Configuration.create
      event = StartedEvent.create(configuration: configuration)
      assert_match /started/, event.message
    end

  end
end