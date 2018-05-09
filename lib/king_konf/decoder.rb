require "king_konf/duration_decoder"

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

    def symbol(value, **)
      value.to_sym
    end

    def list(value, sep: ",", items: :string)
      value.split(sep).map {|s| public_send(items, s) }
    end

    def integer(value, **)
      Integer(value)
    rescue ArgumentError
      raise ConfigError, "#{value.inspect} is not an integer"
    end

    def float(value, **)
      Float(value)
    end

    def duration(value, **)
      case value
      when ""
        nil
      when/^\d*\.\d+$/
        value.to_f
      when/^\d*$/
        value.to_i
      else
        DurationDecoder.decode(value)
      end
    end
  end
end
