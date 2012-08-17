require_relative "test_helper"

module ActiveWorker
  class TestTemplate < ActiveSupport::TestCase

    test "can find all with name" do
      Template.create(configuration_type: Configuration.name)
      Template.create name: "template", configuration_type: Configuration.name

      assert_equal 1, ActiveWorker::Template.with_names(Configuration).count
    end
  end

end