module ActiveWorker
  module Behavior
    module HasModes

      class ModeNotSupportedException < StandardError
      end

      module ClassExtensions

        def modes_map
          @modes_map ||= ModesMap.new
        end

        def modes
          modes_map.modes
        end

        def add_mode(*args)
          modes_map.add_mode(*args)
        end
      end

      def self.included(base)
        base.extend(ClassExtensions)
        base.field :mode
        base.before_save :set_mode_defined_fields
      end

      def set_mode_defined_fields
        unless mode.nil? || mode.empty?
          if self.class.modes_map.supports? mode
            self.class.modes_map.mode(mode).each_pair do |field, value|
              write_attribute(field, value) unless read_attribute(field)
            end
          else
            raise ModeNotSupportedException, "Mode \"#{mode}\" not in Modes List: #{self.class.modes} for #{self.class}"
          end
        end
      end

    end
  end

end