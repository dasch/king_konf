require "king_konf"

describe KingKonf::Config do
  let(:config_class) {
    Class.new(KingKonf::Config) do
      env_prefix :test

      string :greeting, required: true

      symbol :type, required: true

      desc "pitch level"
      integer :level, default: 0, allowed_values: 0..99

      desc "whether greeting is enabled"
      boolean :enabled, default: false

      boolean :awesome, default: true

      list :phrases, sep: ";", items: :string

      float :happiness, default: 1.0

      duration :time_to_sleep, default: "8h"

      integer :even_number, validate_with: ->(int) { int % 2 == 0 }
    end
  }

  let(:config) { config_class.new }

  it "allows adding a description to variables" do
    expect(config_class.variable(:level).description).to eq "pitch level"
    expect(config_class.variable(:enabled).description).to eq "whether greeting is enabled"
    expect(config_class.variable(:phrases).description).to eq nil
  end

  describe "#validate!" do
    it "raises ConfigError if a required variable is missing" do
      expect {
        config.validate!
      }.to raise_exception(KingKonf::ConfigError, "required variable `greeting` is not defined")
    end

    it "raises ConfigError if a value is not in the allowed set" do
      expect {
        config.level = 100
      }.to raise_exception(KingKonf::ConfigError, "invalid value 100 for variable `level`, allowed values are 0..99")
    end

    it "casts values before checking if they're in the allowed set" do
      expect {
        config.level = "99"
      }.to_not raise_exception
    end

    it "raises ConfigError if a value is not valid" do
      expect {
        config.even_number = 3
      }.to raise_exception(KingKonf::ConfigError, "invalid value 3 for variable `even_number`")
    end
  end

  describe "#decode" do
    it "allows decoding strings into the variable's type" do
      config.decode(:level, "99")

      expect(config.level).to eq 99
    end

    it "raises ConfigError if the value cannot be decoded" do
      expect {
        config.decode(:level, "XXX")
      }.to raise_exception(KingKonf::ConfigError, '"XXX" is not an integer')
    end
  end

  describe "object API" do
    it "allows defining string variables" do
      expect(config.greeting).to eq nil

      config.greeting = "hello!"

      expect(config.greeting).to eq "hello!"
    end

    it "allows defining symbol variables" do
      expect(config.type).to eq nil

      config.type = :symbolized

      expect(config.type).to eq :symbolized

      expect {
        config.type = 42
      }.to raise_exception(KingKonf::ConfigError, "invalid value 42 for variable `type`, expected symbol")
    end

    it "allows defining integer variables" do
      expect(config.level).to eq 0

      config.level = 99

      expect(config.level).to eq 99

      expect {
        config.level = "yolo"
      }.to raise_exception(KingKonf::ConfigError, 'invalid value "yolo" for variable `level`, expected integer')
    end

    it "allows defining float variables" do
      expect(config.happiness).to eq 1.0

      config.happiness = 0.5

      expect(config.happiness).to eq 0.5

      # Setting an integer is okay:
      config.happiness = 0

      expect {
        config.happiness = "yolo"
      }.to raise_exception(KingKonf::ConfigError, 'invalid value "yolo" for variable `happiness`, expected float')
    end

    it "allows defining duration variables" do
      expect(config.time_to_sleep).to eq (8 * 60 * 60)

      config.time_to_sleep = "1h 30m"

      expect(config.time_to_sleep).to eq (60 * 60 + 30 * 60)

      expect {
        config.time_to_sleep = "forever"
      }.to raise_exception(KingKonf::ConfigError, '"forever" is not a duration: must be e.g. `1h 30m`')
    end

    it "allows defining boolean variables" do
      expect(config.enabled).to eq false

      config.enabled = true

      expect(config.enabled).to eq true
      expect(config.enabled?).to eq true

      expect {
        config.enabled = "yolo"
      }.to raise_exception(KingKonf::ConfigError, '"yolo" is not a boolean: must be one of true, 1, false, 0')
    end

    it "allows setting boolean variables to false" do
      expect(config.awesome).to eq true

      config.awesome = false

      expect(config.awesome).to eq false
      expect(config.awesome?).to eq false
    end

    it "allows setting variables to nil" do
      config.greeting = "hello"
      config.greeting = nil

      expect(config.greeting).to eq nil
    end
  end

  describe "environment variable API" do
    it "allows setting variables through the ENV" do
      env = {
        "TEST_GREETING" => "hello",
        "TEST_LEVEL" => "42",
        "TEST_ENABLED" => "true",
        "TEST_PHRASES" => "hello, world!;goodbye!;yolo!",
      }

      config = config_class.new(env: env)

      expect(config.greeting).to eq "hello"
      expect(config.level).to eq 42
      expect(config.enabled).to eq true
      expect(config.phrases).to eq ["hello, world!", "goodbye!", "yolo!"]
    end

    it "raises ConfigError if an unknown variable is passed in the ENV" do
      env = {
        "TEST_MISSING" => "hello",
      }

      expect {
        config_class.new(env: env)
      }.to raise_exception(KingKonf::ConfigError, "All environment variables starting with `TEST_` must by valid configuration variables, but `TEST_MISSING` does not match any such variable")
    end

    it "can be configured to ignore unknown variables" do
      config_class = Class.new(KingKonf::Config) do
        env_prefix :test
        ignore_unknown_variables true

        string :greeting
      end

      env = {
        "TEST_MISSING" => "hello",
      }

      expect {
        config_class.new(env: env)
      }.not_to raise_exception
    end
  end
end
