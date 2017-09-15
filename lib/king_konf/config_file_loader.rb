require "erb"
require "yaml"

module KingKonf
  class ConfigFileLoader
    def initialize(config)
      @config = config
    end

    def load_file(path, environment = nil)
      # First, load the ERB template from disk.
      template = ERB.new(File.new(path).read)

      # The last argument to `safe_load` allows us to use aliasing to share
      # configuration between environments.
      data = YAML.safe_load(template.result(binding), [], [], true)

      # Grab just the config for the environment, if specified.
      data = data.fetch(environment) unless environment.nil?

      data.each do |variable, value|
        @config.set(variable, value)
      end
    end
  end
end
