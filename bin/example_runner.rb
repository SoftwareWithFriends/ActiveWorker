#!/usr/bin/env ruby

bin_dir = File.dirname(__FILE__)
examples_dir = File.join(bin_dir, "..", "examples")
active_worker_lib = File.join(bin_dir, "..", "lib")

$LOAD_PATH.unshift active_worker_lib
require 'active_worker'

current_example_dir = File.join(examples_dir, "test_worker")

Dir.glob("#{current_example_dir}/**/*.rb").each do |source|
  load source
end

def print_events(configurations)
  configurations.flat_map(&:events).each do |event|
    puts "#{event.event_type} #{event.host} #{event.process_id} #{event.worker_pid} #{event.message}"
  end
end

def print_configurations(configurations)
  configurations.each do |config|
    puts "Configuration: #{config.defined_fields}"
  end
end


ENV['MONGOID_ENV'] = 'example_runner'
Mongoid.load! 'examples/mongoid.yml'
ActiveWorker::JobQueue::RunRemotely.worker_mode = ActiveWorker::JobQueue::RunRemotely::THREADED

configuration = TestWorker::Configuration.create duration: 5, delay_between_requests: 1.0
configurations = configuration.launch
print_configurations(configurations)
configurations.map(&:wait_until_completed)
print_events(configurations)
