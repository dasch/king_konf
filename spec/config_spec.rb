require "king_konf"

describe KingKonf::Config do
  let(:config_class) {
    Class.new(KingKonf::Config) do
      string :greeting
      integer :level, default: 0
      boolean :enabled, default: false
      list :phrases, sep: ";", items: :string
    end
  }

  let(:config) { config_class.new }

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
end
