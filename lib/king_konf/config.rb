require "king_konf/decoder"
require "king_konf/config_file_loader"

module KingKonf
  class Variable
    attr_reader :name, :type, :default, :description, :options

    def initialize(name, type, default, description, options)
      @name, @type, @default = name, type, default
      @description = description
      @options = options
    end

    def valid?(value)
      case @type
      when :string then value.is_a?(String) || value.nil?
      when :list then value.is_a?(Array)
      when :integer then value.is_a?(Integer) || value.nil?
      when :boolean then value == true || value == false
      else raise "invalid type #{@type}"
      end
    end

    def decode(value)
      Decoder.public_send(@type, value, **options)
    end
  end

  class Config
    @variables = {}

    class << self
      def prefix(prefix = nil)
        @prefix = prefix if prefix
        @prefix
      end

      def variable(name)
        @variables.fetch(name.to_s)
      end

      def variable?(name)
        @variables.key?(name.to_s)
      end

      def variables
        @variables.values
      end

      %i(boolean integer string list).each do |type|
        define_method(type) do |name, default: nil, **options|
          description, @desc = @desc, nil
          variable = Variable.new(name, type, default, description, options)

          @variables ||= {}
          @variables[name.to_s] = variable

          define_method(name) do
            get(name)
          end

          define_method("#{name}=") do |value|
            set(name, value)
          end
        end
      end

      private

      def desc(description)
        @desc = description
      end
    end

    def initialize(env: ENV)
      load_env(env)
    end

    def load_file(path, environment = nil)
      loader = ConfigFileLoader.new(self)
      loader.load_file(path, environment)
    end

    def get(name)
      if value = instance_variable_get("@#{name}")
        value
      else
        variable = self.class.variable(name)
        variable.default
      end
    end

    def decode(name, value)
      decoded_value = self.class.variable(name).decode(value)

      set(name, decoded_value)
    end

    def set(name, value)
      unless self.class.variable?(name)
        raise ConfigError, "unknown configuration variable #{name}"
      end

      variable = self.class.variable(name)

      if variable.valid?(value)
        instance_variable_set("@#{name}", value)
      else
        raise ConfigError, "invalid value #{value.inspect}, expected #{variable.type}"
      end
    end

    private

    def load_config(config)
      config.each do |variable, value|
        set(variable, value)
      end
    end

    def load_env(env)
      loaded_keys = []
      prefix = self.class.prefix ? "#{self.class.prefix.upcase}_" : ""

      self.class.variables.each do |variable|
        key = prefix + variable.name.upcase.to_s

        if string = env[key]
          value = variable.decode(string)
          set(variable.name, value)
          loaded_keys << key
        end
      end

      # Only complain about unknown ENV vars if there's a prefix defined.
      if self.class.prefix
        env.keys.grep(/^#{prefix}/).each do |key|
          unless loaded_keys.include?(key)
            raise ConfigError, "unknown environment variable #{key}"
          end
        end
      end
    end
  end
end
