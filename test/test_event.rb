require_relative "test_helper"

module ActiveWorker
  class EventTest < ActiveSupport::TestCase

    test "can find event for root object" do
      top_level_object = Configuration.create
      config = Configuration.create root_object: top_level_object

      event =Event.create configuration: config

      assert_equal event, ActiveWorker::Event.for_root_object_id(top_level_object.id).first
    end

    test "field events for view" do
      config = Configuration.create
      event = Event.create configuration: config, message: "this is the message"

      fields = event.fields_for_view

      assert_equal "this is the message", fields["message"]
      assert_equal config.id, fields["configuration_id"]
    end

    test "sets host information" do
      config = Configuration.create
      HostInformation.expects(:hostname).returns("test")
      event = Event.create configuration: config
      assert_equal "test", event.host
    end

    test "sets pid" do
      config = Configuration.create
      Event.any_instance.stubs(:get_pid).returns(12345)
      event = Event.create configuration: config
      assert_equal 12345, event.process_id
    end

    test "events must be owned by a configuration" do
      assert_raise Mongoid::Errors::Validations do
        Event.create!
      end
    end

    test "exists with array of configurations" do
      config1 = Configuration.create
      config2 = Configuration.create
      config3 = Configuration.create

      Event.create configuration: config1
      Event.create configuration: config2

      configs = [config1, config2, config3]

      assert_equal false, Event.exists_for_configurations?(configs)

      Event.create configuration: config3

      assert Event.exists_for_configurations?(configs)
    end

  end
end
