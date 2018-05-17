require "king_konf"

RSpec.describe KingKonf::Variable do
  describe "#boolean?" do
    it "returns true if the variable is boolean" do
      variable = KingKonf::Variable.new(
        name: :tall,
        type: :boolean,
      )
      
      expect(variable.boolean?).to eq true
    end
  end

  context "symbol" do
    let(:var) { KingKonf::Variable.new(name: "codec", type: :symbol) }

    it "casts strings" do
      expect(var.cast("gzip")).to eq :gzip
    end

    it "doesn't cast integers" do
      expect(var.cast(90)).to eq 90
    end

  end
  context "duration" do
    let(:var) { KingKonf::Variable.new(name: "timeout", type: :duration) }

    it "casts strings" do
      expect(var.cast("1m 30s")).to eq 90
    end

    it "doesn't cast integers" do
      expect(var.cast(90)).to eq 90
    end
  end
end
