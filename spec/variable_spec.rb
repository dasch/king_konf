require "king_konf/variable"

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
end
