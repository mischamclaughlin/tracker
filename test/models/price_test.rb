require "test_helper"

describe Price do
  let(:coin) { coins(:bitcoin) }
  let(:price) { prices(:bitcoin_current_price) }

  context "when calling public methods" do
    describe "#to_s" do
      it "returns a string representation of the price" do
        expected_string = "
        Coin ID: #{coin.id},
        Price: $#{price.price.to_s('F')},
        Recorded At: #{price.recorded_at.strftime('%d/%m/%Y %H:%M:%S')}
        ".squish

        assert_equal expected_string, price.to_s
      end
    end
  end

  describe "associations" do
    it "belongs to a coin" do
      assert_equal coin, price.coin
    end
  end
end
