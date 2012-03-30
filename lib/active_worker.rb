require 'mongoid'
Dir.glob("#{File.dirname(__FILE__)}/active_worker/**/*.rb").each do |file|
  require file
end
