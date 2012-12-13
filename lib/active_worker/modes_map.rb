module ActiveWorker
  class ModesMap

    attr_reader :modes_hash

    def initialize
      @modes_hash = Hash.new do |hash, key|
        inner_hash = {}
        hash[key] = inner_hash
        inner_hash
      end
    end

    def add_mode(mode_name, field_maps)
      modes_hash[normalize_mode_name(mode_name)].merge! field_maps
    end

    def normalize_mode_name(mode_name)
      mode_name.to_sym
    end

    def modes
      modes_hash.keys
    end

    def supports?(mode_name)
      modes.include? normalize_mode_name(mode_name)
    end

    def mode(mode_name)
      if supports? mode_name
        modes_hash[normalize_mode_name(mode_name)]
      end
    end

  end
end
