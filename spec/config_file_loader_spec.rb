require "king_konf/config"
require "king_konf/config_file_loader"

RSpec.describe KingKonf::ConfigFileLoader do
  let(:config_class) {
    Class.new(KingKonf::Config) do
      string :greeting
    end
  }

  let(:config) { config_class.new }
  let(:loader) { described_class.new(config) }

  it "loads configuration from a YAML file" do
    loader.load_file("spec/fixtures/config.yml", "production")

    expect(config.greeting).to eq "hello"
  end
end
