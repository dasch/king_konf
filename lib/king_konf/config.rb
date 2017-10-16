require "king_konf/variable"
require "king_konf/config_file_loader"

module KingKonf
  class Config
    @variables = {}

    class << self
      def env_prefix(prefix = nil)
        @env_prefix = prefix if prefix
        @env_prefix
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

      %i(boolean integer float string list).each do |type|
        define_method(type) do |name, default: nil, required: false, **options|
          description, @desc = @desc, nil
          variable = Variable.new(
            name: name,
            type: type,
            default: default,
            required: required,
            description: description,
            options: options,
          )

          @variables ||= {}
          @variables[name.to_s] = variable

          define_method(name) do
            get(name)
          end

          if variable.boolean?
            alias_method("#{name}?", name)
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
        instance_variable_set("@#{name}", variable.cast(value))
      else
        raise ConfigError, "invalid value #{value.inspect} for variable `#{name}`, expected #{variable.type}"
      end
    end

    def validate!
      self.class.variables.each do |variable|
        if variable.required? && get(variable.name).nil?
          raise ConfigError, "required variable `#{variable.name}` is not defined"
        end
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
      prefix = self.class.env_prefix ? "#{self.class.env_prefix.upcase}_" : ""

      self.class.variables.each do |variable|
        key = prefix + variable.name.upcase.to_s

        if string = env[key]
          value = variable.decode(string)
          set(variable.name, value)
          loaded_keys << key
        end
      end

      # Only complain about unknown ENV vars if there's a prefix defined.
      if self.class.env_prefix
        env.keys.grep(/^#{prefix}/).each do |key|
          unless loaded_keys.include?(key)
            raise ConfigError, "unknown environment variable #{key}"
          end
        end
      end
    end
  end
end
