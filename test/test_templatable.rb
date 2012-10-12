require_relative "test_helper"

module ActiveWorker
  class TemplatableTest < ActiveSupport::TestCase

    test "can get input string with empty template_name" do
      config = TemplatableTopConfig.create template_name: ""
      string = "New Name"

      assert_not_nil config.template_name
      assert_equal "", config.template_name
      assert_equal string, config.template_name_or(string)
    end

    test "can get template_name" do
      config = TemplatableTopConfig.create template_name: "Template Name"
      string = "New Name"

      assert_equal "Template Name", config.template_name_or(string)
    end

  end
end