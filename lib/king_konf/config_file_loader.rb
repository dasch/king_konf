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

      begin
        data = YAML.load(template.result(binding), aliases: true)
      rescue ArgumentError
        data = YAML.load(template.result(binding))
      end

      # Grab just the config for the environment, if specified.
      data = data.fetch(environment) unless environment.nil?

      data.each do |variable, value|
        @config.set(variable, value)
      end
    end
  end
end
