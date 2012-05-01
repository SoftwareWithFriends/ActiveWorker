require 'mongoid'

require 'active_worker/job_queue/run_remotely'
require 'active_worker/job_queue/job_executer'

require 'active_worker/behavior/acts_as_root_object'
require 'active_worker/behavior/has_root_object'
require 'active_worker/behavior/hashable'

require 'active_worker/event'
require 'active_worker/notification_event'
require 'active_worker/finished_event'
require 'active_worker/failure_event'

require 'active_worker/configuration'
require 'active_worker/controller'

require 'active_worker/host_information'
require 'active_worker/templatable'

#Load anything else that is missing.
Dir.glob("#{File.dirname(__FILE__)}/active_worker/**/*.rb").each do |file|
  require file
end

