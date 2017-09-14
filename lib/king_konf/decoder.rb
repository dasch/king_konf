module KingKonf
  module Decoder
    extend self

    def boolean(value, true_values: ["true", "1"], false_values: ["false", "0"])
      if true_values.include?(value)
        true
      elsif false_values.include?(value)
        false
      else
        values = true_values + false_values
        raise ConfigError, "#{value.inspect} is not a boolean: must be one of #{values.join(', ')}"
      end
    end

    def string(value, **)
      value
    end

    def list(value, sep: ",", items: :string)
      value.split(sep).map {|s| public_send(items, s) }
    end

    def integer(value, **)
      Integer(value)
    rescue ArgumentError
      raise ConfigError, "#{value.inspect} is not an integer"
    end
  end
end
