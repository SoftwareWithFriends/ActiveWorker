require_relative "test_helper"

module ActiveWorker
  class FailureEventTest < ActiveSupport::TestCase

    test "can create a failure event from error and basic params" do
      exception = create_exception

      config = ActiveWorker::Configuration.create

      original_event = FailureEvent.from_error(config, exception)

      event = FailureEvent.where(configuration_id: config.id).first

      assert_equal original_event, event
      assert_equal exception.backtrace.join("\n"), event.stack_trace
    end


    test "can use failure events as finished events" do
      exception = create_exception
      config = ActiveWorker::Configuration.create

      original_event = FailureEvent.from_error(config,exception)
      event = FinishedEvent.where(configuration_id: config.id).first

      assert_equal original_event, event
    end



  end
end
