require_relative "test_helper"

module ActiveWorker
  class TerminationEventTest < ActiveSupport::TestCase

    test "expands for threads" do
      config = ExpandableConfig.create number_of_threads: 2

      config.expand_for_threads

      events = TerminationEvent.from_termination(config)

      assert_equal 2, events.size
    end

    test "expands for threads unless completed" do
      config = ExpandableConfig.create number_of_threads: 2

      config.expand_for_threads

      config.finished

      events = TerminationEvent.from_termination(config)

      assert_equal 1, events.size
    end
  end
end
