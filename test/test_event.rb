require_relative "test_helper"

module ActiveWorker
  class EventTest < ActiveSupport::TestCase

    test "can find event for root object" do
      top_level_object = Configuration.create
      config = Configuration.create root_object: top_level_object

      event = ActiveWorker::Event.create configuration: config

      assert_equal event, ActiveWorker::Event.for_root_object_id(top_level_object.id).first
    end

    test "field events for view" do
      config = Configuration.create
      event = ActiveWorker::Event.create configuration: config, message: "this is the message"

      fields = event.fields_for_view

      assert_equal "this is the message", fields["message"]
      assert_equal config.id, fields["configuration_id"]
    end

    test "sets host information" do
      config = Configuration.create
      HostInformation.expects(:hostname).returns("test")
      event = ActiveWorker::Event.create configuration: config
      assert_equal "test", event.host
    end

    test "events must be owned by a configuration" do
      assert_raise Mongoid::Errors::Validations do
        ActiveWorker::Event.create!
      end
    end

  end
end
