require "king_konf/decoder"

module KingKonf
  class Variable
    attr_reader :name, :type, :default, :description, :allowed_values, :validate_with, :options

    def initialize(name:, type:, default: nil, description: "", required: false, allowed_values: nil, validate_with: ->(_) { true }, options: {})
      @name, @type = name, type
      @description = description
      @required = required
      @allowed_values = allowed_values
      @options = options
      @default = cast(default) unless default.nil?
      @validate_with = validate_with
    end

    def cast(value)
      case @type
      when :boolean then [true, false].include?(value) ? value : Decoder.boolean(value, **options)
      when :integer then Integer(value)
      when :float then Float(value)
      when :duration then value.is_a?(Integer) ? value : Decoder.duration(value)
      when :symbol then value.to_sym
      else value
      end
    rescue ArgumentError, NoMethodError
      raise ConfigError, "invalid value #{value.inspect} for variable `#{name}`, expected #{type}"
    end

    def required?
      @required
    end

    def valid?(value)
      cast_value = cast(value)
    rescue ConfigError
      false
    else
      !!validate_with.call(cast_value)
    end

    def allowed?(value)
      allowed_values.nil? || allowed_values.include?(cast(value))
    rescue ConfigError
      false
    end

    def decode(value)
      Decoder.public_send(@type, value, **options)
    end

    TYPES.each do |type|
      define_method("#{type}?") do
        @type == type
      end
    end
  end
end
