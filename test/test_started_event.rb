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

  end
end