require 'mongoid'

#Load sub directories first
Dir.glob("#{File.dirname(__FILE__)}/active_worker/*/**/*.rb").each do |file|
  require file
end

Dir.glob("#{File.dirname(__FILE__)}/active_worker/**/*.rb").each do |file|
  require file
end

