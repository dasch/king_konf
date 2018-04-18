require "king_konf"

describe KingKonf::Decoder do
  describe ".boolean" do
    it "decodes `true`, `false`, `1`, and `0`" do
      expect(KingKonf::Decoder.boolean("true")).to eq true
      expect(KingKonf::Decoder.boolean("1")).to eq true
      expect(KingKonf::Decoder.boolean("false")).to eq false
      expect(KingKonf::Decoder.boolean("0")).to eq false
    end

    it "raises ConfigError on other values" do
      expect {
        KingKonf::Decoder.boolean("hello")
      }.to raise_exception(KingKonf::ConfigError, '"hello" is not a boolean: must be one of true, 1, false, 0')
    end
  end

  describe ".float" do
    it "decodes floats" do
      expect(KingKonf::Decoder.float("1.5")).to eq 1.5
    end
  end

  describe ".symbol" do
    it 'decodes string as symbol' do
      expect(KingKonf::Decoder.symbol("string")).to eq :string
    end
  end
end
