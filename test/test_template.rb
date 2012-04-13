require_relative "test_helper"

class TestTemplate < ActiveSupport::TestCase

  test "can find all with name" do
    ActiveWorker::Template.create
    ActiveWorker::Template.create name: "template"

    assert_equal 1, ActiveWorker::Template.with_names.count
  end


end