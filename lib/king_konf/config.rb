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

      def ignore_unknown_variables(should_ignore)
        @ignore_unknown_variables = should_ignore
      end

      def ignore_unknown_variables?
        # Always ignore about unknown ENV vars if there's no prefix defined.
        @ignore_unknown_variables || !env_prefix
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

      TYPES.each do |type|
        define_method(type) do |name, default: nil, required: false, allowed_values: nil, validate_with: ->(_) { true }, **options|
          description, @desc = @desc, nil if defined?(@desc)
          variable = Variable.new(
            name: name,
            type: type,
            default: default,
            required: required,
            description: description,
            allowed_values: allowed_values,
            validate_with: validate_with,
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
      @desc = nil
      @ignore_unknown_variables = nil
      load_env(env)
    end

    def load_file(path, environment = nil)
      loader = ConfigFileLoader.new(self)
      loader.load_file(path, environment)
    end

    def get(name)
      if instance_variable_defined?("@#{name}")
        instance_variable_get("@#{name}")
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

      cast_value = value.nil? ? nil : variable.cast(value)

      if !variable.allowed?(cast_value)
        raise ConfigError, "invalid value #{value.inspect} for variable `#{name}`, allowed values are #{variable.allowed_values}"
      end

      if !variable.valid?(value)
        raise ConfigError, "invalid value #{value.inspect} for variable `#{name}`"
      end

      instance_variable_set("@#{name}", cast_value)
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


      unless self.class.ignore_unknown_variables?
        env.keys.grep(/^#{prefix}/).each do |key|
          unless loaded_keys.include?(key)
            raise ConfigError, "unknown environment variable #{key}"
          end
        end
      end
    end
  end
end
