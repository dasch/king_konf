require "king_konf/version"

module KingKonf
  # Variable value types.
  TYPES = %i(boolean integer float string list symbol)

  ConfigError = Class.new(StandardError)
end

require "king_konf/config"
