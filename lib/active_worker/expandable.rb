module ActiveWorker
  module Expandable

    def self.included(base)
      base.template_field :number_of_threads, type: Integer, default: 1
      base.template_field :number_of_workers, type: Integer, default: 1
      base.belongs_to :thread_root_configuration, :polymorphic => true
      base.has_many :thread_expanded_configurations,
                    :as => :thread_root_configuration,
                    :class_name => 'ActiveWorker::Configuration',
                    :autosave => true
    end

    def expand_for_threads
      maps = expansion_maps_for_threads
      maps[1..-1].each do |map_hash|
        map_hash[:thread_root_configuration_id] = id
        map_hash[:thread_root_configuration_type] = _type
      end
      expand_from_maps(maps)
    end

    def expand_for_workers
      maps = expansion_maps_for_workers
      expand_from_maps(maps)
    end

    def configurations_for_events
      [self] + thread_expanded_configurations
    end

    private

    def expand_from_maps(maps)
      first_config = true
      maps.map do |map_hash|
        if first_config
          first_config = false
          modify_for_expansion(map_hash)
        else
          create_for_expansion(map_hash)
        end
      end
    end

    def create_for_expansion(options = {})
      self.class.create(defined_fields.merge(parent_configuration: parent_configuration,
                                             root_object_id: root_object_id,
                                             root_object_type: root_object_type).merge(options))
    end

    def modify_for_expansion(options = {})
      self.update_attributes!(options)
      self
    end


    def expansion_maps_for_workers
      expansion_maps_for(number_of_workers)
    end

    def expansion_maps_for_threads
      expansion_maps_for(number_of_threads)

    end

    def expansion_maps_for(number_of_configurations)
      maps = []
      number_of_configurations.times do
        maps << {}
      end
      maps
    end

  end
end