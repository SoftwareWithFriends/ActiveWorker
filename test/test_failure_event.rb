require_relative "test_helper"

module ActiveWorker
  class FailureEventTest < ActiveSupport::TestCase

    test "can create a failure event from error and basic params" do
      exception = create_exception

      config = ActiveWorker::Configuration.create

      original_events = FailureEvent.from_error(config, exception)
      assert_equal 1, original_events.size
      original_event = original_events.first

      event = FailureEvent.where(configuration_id: config.id).first

      assert_equal original_event, event
      assert_equal exception.backtrace.join("\n"), event.stack_trace
      assert_equal "Mocha::Mock", event.error_type
    end

    test "event name and error message are used in event display" do
      exception = create_exception
      config = ActiveWorker::Configuration.create

      original_event = FailureEvent.from_error(config, exception).first

      assert_match /#{config.event_name}/, original_event.message
      assert_match /#{exception.message}/, original_event.message
    end

    test "can use failure events as finished events" do
      exception = create_exception
      config = ActiveWorker::Configuration.create
      original_event = FailureEvent.from_error(config,exception).first
      event = FinishedEvent.where(configuration_id: config.id).first

      assert_equal original_event, event
    end

    test "expands for threads unless completed" do
      exception = create_exception

      config = ExpandableConfig.create number_of_threads: 2

      config.expand_for_threads

      events = FailureEvent.from_error(config, exception)

      assert_equal 2, events.size
    end

    test "expands for threads" do
      exception = create_exception

      config = ExpandableConfig.create number_of_threads: 2

      config.expand_for_threads
      config.finished

      events = FailureEvent.from_error(config, exception)

      assert_equal 1, events.size
    end



  end
end
