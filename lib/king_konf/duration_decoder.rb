module KingKonf
  # Decodes specially formatted duration strings.
  module DurationDecoder
    UNITS = {
      "ms" => 0.001,
      "s"  => 1,
      "m"  => 60,
      "h"  => 60 * 60,
      "d"  => 60 * 60 * 24,
      "w"  => 60 * 60 * 24 * 7,
    }

    # Either a number or a time unit.
    PART = /(\d+|#{UNITS.keys.join('|')})/

    # One or more parts, possibly separated by whitespace.
    VALID_DURATION = /^(#{PART}\s*)+$/


    def self.decode(value)
      if value !~ VALID_DURATION
        raise ConfigError, "#{value.inspect} is not a duration: must be e.g. `1h 30m`"
      end

      value.scan(PART).flatten.each_slice(2).map {|number, letter|
        number.to_i * UNITS.fetch(letter)
      }.sum
    end
  end
end
