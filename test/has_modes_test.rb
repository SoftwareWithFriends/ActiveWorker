require_relative "test_helper"

module ActiveWorker
  class Modeable
    include Mongoid::Document
    include ActiveWorker::Behavior::HasModes

    field :custom_field

    add_mode :first, custom_field: "mode1", other_field: "default"
    add_mode :second, custom_field: "mode2"
  end


  class HasModesTest < ActiveSupport::TestCase
    test "can specify modes" do
      mode_config = Modeable.create mode: :first

      assert_equal [:first, :second], Modeable.modes
      assert_equal :first, mode_config.mode
    end

    test "sets custom fields with mode map" do
      mode_config = Modeable.create mode: :first
      assert_equal "mode1", mode_config.custom_field
      assert_equal "default", mode_config.other_field
    end

    test "mode does not override already set field" do
      mode_config = Modeable.create mode: :first, custom_field: "set"
      assert_equal "set", mode_config.custom_field
    end

    test "does not blow up with unsupported mode" do
      assert_raise ActiveWorker::Behavior::HasModes::ModeNotSupportedException do
        Modeable.create mode: "foo"
      end
    end

    test "allows no mode to be set" do
      mode_config = Modeable.create custom_field: "set"
      assert_equal "set", mode_config.custom_field
    end

  end


end