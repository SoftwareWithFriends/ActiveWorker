# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "active_worker"
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["perf"]
  s.date = "2013-05-03"
  s.description = "Uses a Configuration/Controller pattern to allow easy implementation and organziation of multi-tier distributed workloads."
  s.email = "perf@skarven.net"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rvmrc",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "active_worker.gemspec",
    "lib/active_worker.rb",
    "lib/active_worker/behavior/acts_as_root_object.rb",
    "lib/active_worker/behavior/can_be_notified.rb",
    "lib/active_worker/behavior/has_modes.rb",
    "lib/active_worker/behavior/has_root_object.rb",
    "lib/active_worker/behavior/hashable.rb",
    "lib/active_worker/configuration.rb",
    "lib/active_worker/controller.rb",
    "lib/active_worker/event.rb",
    "lib/active_worker/expandable.rb",
    "lib/active_worker/failure_event.rb",
    "lib/active_worker/finished_event.rb",
    "lib/active_worker/host_information.rb",
    "lib/active_worker/job_queue/job_executer.rb",
    "lib/active_worker/job_queue/queue_manager.rb",
    "lib/active_worker/job_queue/run_remotely.rb",
    "lib/active_worker/modes_map.rb",
    "lib/active_worker/notification_event.rb",
    "lib/active_worker/started_event.rb",
    "lib/active_worker/templatable.rb",
    "lib/active_worker/template.rb",
    "lib/active_worker/termination_event.rb",
    "test/mongoid.yml",
    "test/test_acts_as_root_object.rb",
    "test/test_can_be_notified.rb",
    "test/test_configuration.rb",
    "test/test_controller.rb",
    "test/test_event.rb",
    "test/test_expandable.rb",
    "test/test_failure_event.rb",
    "test/test_finished_event.rb",
    "test/test_has_modes.rb",
    "test/test_helper.rb",
    "test/test_integration.rb",
    "test/test_job_executer.rb",
    "test/test_queue_manager.rb",
    "test/test_run_remotely.rb",
    "test/test_started_event.rb",
    "test/test_templatable.rb",
    "test/test_template.rb",
    "test/test_termination_event.rb"
  ]
  s.homepage = "http://github.com/ryanmcgarvey/active_worker"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Framework for making class distributable on a queueing system."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mongoid>, [">= 0"])
      s.add_runtime_dependency(%q<bson_ext>, [">= 0"])
      s.add_runtime_dependency(%q<resque>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.3"])
    else
      s.add_dependency(%q<mongoid>, [">= 0"])
      s.add_dependency(%q<bson_ext>, [">= 0"])
      s.add_dependency(%q<resque>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
    end
  else
    s.add_dependency(%q<mongoid>, [">= 0"])
    s.add_dependency(%q<bson_ext>, [">= 0"])
    s.add_dependency(%q<resque>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.3"])
  end
end

