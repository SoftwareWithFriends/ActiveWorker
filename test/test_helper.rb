require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'active_support/test_case'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'active_worker'

require 'mongoid'
ENV["MONGOID_ENV"]="test"
Mongoid.load!("#{File.dirname(__FILE__)}/mongoid.yml")


Resque.redis.namespace = "resque:active_worker_test"


module ActiveWorker

  class Rootable
    include Mongoid::Document
    include ActiveWorker::Behavior::ActsAsRootObject
  end


  class TopConfig < Configuration
    config_field :top_field

    def child_configs
      ChildConfig.mine(self).all
    end
  end

  class ChildConfig < Configuration
    config_field :child_field
  end

  class TemplatableTopConfig < Configuration
    include Templatable
    template_field :top_field
    config_field :other_top_field
  end

  class TemplatableChildConfig < Configuration
    include Templatable
    template_field :child_field
    config_field :other_child_field
  end

  class AfterLaunchConfig < ActiveWorker::Configuration
    after_launch :after_launch_method
  end

  class ExpandableConfig < Configuration
    include Expandable
    include Templatable
    field :foo
    template_field :name
    config_field :size
  end

  class MappedExpandableConfig < ExpandableConfig
    def expansion_maps_for(number_of_configurations)
      maps = []
      number_of_configurations.times do |value|
        maps << {size: value}
      end
      maps
    end
  end

end


class ActiveSupport::TestCase
  def create_exception
    error_message = "Error message"
    error_backtrace = ["line 1", "line 2"]

    error = mock
    error.stubs(:message).returns(error_message)
    error.stubs(:backtrace).returns(error_backtrace)
    error
  end

  setup :clear_database

  private

  def clear_database
    Mongoid.default_session.collections.select { |c| c.name != 'system.indexes' }.each(&:drop)
  end

end

ActiveWorker::JobQueue::JobExecuter.stubs(:log_error)
