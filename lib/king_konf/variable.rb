require "king_konf/decoder"

module KingKonf
  class Variable
    attr_reader :name, :type, :default, :description, :options

    def initialize(name:, type:, default: nil, description: "", required: false, options: {})
      @name, @type, @default = name, type, default
      @description = description
      @required = required
      @options = options
    end

    def cast(value)
      case @type
      when :float then value.to_f
      else value
      end
    end

    def required?
      @required
    end

    def valid?(value)
      case @type
      when :string then value.is_a?(String) || value.nil?
      when :list then value.is_a?(Array)
      when :integer then value.is_a?(Integer) || value.nil?
      when :float then value.is_a?(Float) || value.is_a?(Integer) || value.nil?
      when :boolean then value == true || value == false
      else raise "invalid type #{@type}"
      end
    end

    def decode(value)
      Decoder.public_send(@type, value, **options)
    end

    %i(boolean integer float string list).each do |type|
      define_method("#{type}?") do
        @type == type
      end
    end
  end
end
