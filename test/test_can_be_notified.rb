require_relative "test_helper"

module ActiveWorker

  class CanBeNotifiedTest < ActiveSupport::TestCase

    class Configuration < ActiveWorker::Configuration
        include Expandable
        config_field :wait_for_notifications, default: true
        config_field :nodes

        def expansion_maps_for_threads
          nodes.split(",").map { |node| {nodes: node} }
        end
      end

      class Controller < ActiveWorker::Controller
        include Behavior::CanBeNotified

        def execute
          sleep 0.1 until configuration.notified?
        end
      end

    test "controller forwards notifications" do
      Controller::ClassMethods::SLEEP_DURATION = 0.1

      nodes = "thread1, thread2, thread3"
      configuration = CanBeNotifiedTest::Configuration.create nodes: nodes

      configuration.launch
      sleep 0.1 until (StartedEvent.count == nodes.split(",").size)
      configuration.notify

      wait_for_all_configurations
      assert_no_failures

      assert_equal 3, ActiveWorker::FinishedEvent.count
    end


  end

end