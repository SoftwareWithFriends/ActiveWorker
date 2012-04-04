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

require 'stalker'


module ActiveWorker

  class Rootable
    include Mongoid::Document
    include ActiveWorker::Behavior::ActsAsRootObject
  end


  class TopConfig < Configuration
    field :top_field

    def child_configs
      ChildConfig.mine(self).all
    end
  end

  class ChildConfig < Configuration
    field :child_field
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
    Mongoid.database.collections.select { |c| c.name != 'system.indexes' }.each(&:drop)
  end

end
