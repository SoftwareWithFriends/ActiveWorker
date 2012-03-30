module ActiveWorker
  module HostInformation

    def self.hostname
      `hostname -f`.chomp
    end

    def self.short_hostname
      `hostname`.chomp
    end

  end
end