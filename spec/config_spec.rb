require "king_konf"

describe KingKonf::Config do
  let(:config_class) {
    Class.new(KingKonf::Config) do
      prefix :test

      string :greeting

      desc "pitch level"
      integer :level, default: 0

      desc "whether greeting is enabled"
      boolean :enabled, default: false

      list :phrases, sep: ";", items: :string
    end
  }

  let(:config) { config_class.new }

  describe "DSL" do
    it "allows adding a description to variables" do
      expect(config_class.variable(:level).description).to eq "pitch level"
      expect(config_class.variable(:enabled).description).to eq "whether greeting is enabled"
      expect(config_class.variable(:phrases).description).to eq nil
    end
  end

  describe "object API" do
    it "allows defining string variables" do
      expect(config.greeting).to eq nil

      config.greeting = "hello!"

      expect(config.greeting).to eq "hello!"

      expect {
        config.greeting = 42
      }.to raise_exception(KingKonf::ConfigError, "invalid value 42, expected string")
    end

    it "allows defining integer variables" do
      expect(config.level).to eq 0

      config.level = 99

      expect(config.level).to eq 99

      expect {
        config.level = "yolo"
      }.to raise_exception(KingKonf::ConfigError, 'invalid value "yolo", expected integer')
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
      }.to raise_exception(KingKonf::ConfigError, "unknown environment variable TEST_MISSING")
    end
  end
end
