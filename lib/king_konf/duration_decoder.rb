module KingKonf
  # Decodes specially formatted duration strings.
  module DurationDecoder
    # Either a number or a time unit.
    REGEX = /(\d+|[wdhms])/

    UNITS = {
      "s" => 1,
      "m" => 60,
      "h" => 60 * 60,
      "d" => 60 * 60 * 24,
      "w" => 60 * 60 * 24 * 7,
    }

    def self.decode(value)
      value.scan(REGEX).flatten.each_slice(2).map {|number, letter|
        number.to_i * UNITS.fetch(letter)
      }.sum
    end
  end
end
