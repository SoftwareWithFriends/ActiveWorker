# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "active_worker"
  gem.homepage = "https://github.com/SoftwareWithFriends/ActiveWorker"
  gem.license = "MIT"
  gem.summary = %Q{Framework for creating and running long-running tasks on a cluster}
  gem.description = %Q{Uses a Configuration/Controller pattern to allow easy implementation and organziation of multi-tier distributed workloads.}
  gem.email = ["mcgarvey.ryan@gmail.com", "buddhistpirate@chubtoad.com", "liukke@gmail.com"]
  gem.authors = ["Ryan McGarvey", "Tim Johnson", "Eric Liu"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end


task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "active_worker #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
