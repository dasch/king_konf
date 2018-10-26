require "king_konf"

RSpec.describe KingKonf::Variable do
  KingKonf::TYPES.each do |type|
    context(type) do
      let(:var) { KingKonf::Variable.new(name: "foo", type: type) }

      it "defaults to nil" do
        expect(var.default).to eq nil
      end
    end
  end

  describe "#allowed" do
    it "casts the value before checking" do
      var = KingKonf::Variable.new(name: "codec", type: :symbol, allowed_values: [:gzip])

      expect(var.allowed?("gzip")).to eq true
    end

    it "returns false if the value is invalid" do
      var = KingKonf::Variable.new(name: "codec", type: :integer, allowed_values: [:gzip])
      
      expect(var.allowed?("yolo")).to eq false
    end
  end

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

    it "marks strings as valid" do
      expect(var.valid?("gzip")).to eq true
    end

    it "casts strings" do
      expect(var.cast("gzip")).to eq :gzip
    end

    it "doesn't cast integers" do
      expect { var.cast(90) }.to raise_exception(KingKonf::ConfigError)
    end
  end

  context "duration" do
    let(:var) { KingKonf::Variable.new(name: "timeout", type: :duration) }

    it "casts strings" do
      expect(var.cast("1m 30s")).to eq 90
    end

    it "doesn't cast integers" do
      expect(var.cast(90)).to eql 90
    end
  end

  context "float" do
    let(:var) { KingKonf::Variable.new(name: "happiness", type: :float) }

    it "casts integers" do
      expect(var.cast(42)).to eql 42.0
    end

    it "casts strings" do
      expect(var.cast("3.141")).to eql 3.141
    end
  end
end
