require "test_helper"

describe Coin do
  let(:portfolio_main) { portfolios(:main) }
  let(:holding_bitcoin_main) { holdings(:main_bitcoin) }
  let(:transaction_buy_bitcoin) { transactions(:buy_bitcoin) }
  let(:transaction_sell_bitcoin) { transactions(:sell_bitcoin) }
  let(:price) { prices(:bitcoin_current_price) }
  let(:coin) { coins(:bitcoin) }

  context "when calling public methods" do
    describe "#to_s" do
      it "returns a string representation of the coin" do
        expected_string = "
        Coin ID: #{holding_bitcoin_main.coin.id},
        Coin Name: #{holding_bitcoin_main.coin.coin_name},
        Coin Symbol: #{holding_bitcoin_main.coin.symbol},
        CoinGecko ID: #{holding_bitcoin_main.coin.coingecko_id},
        Created At: #{holding_bitcoin_main.coin.created_at.strftime('%d/%m/%Y %H:%M:%S')}
        ".squish

        assert_equal expected_string, holding_bitcoin_main.coin.to_s
      end
    end

    describe "#find_by_symbol_or_name" do
      it "returns the correct coin for a given symbol" do
        assert_equal holding_bitcoin_main.coin, Coin.find_by_symbol_or_name(holding_bitcoin_main.coin.symbol)
      end

      it "returns the correct coin for a given name" do
        assert_equal holding_bitcoin_main.coin, Coin.find_by_symbol_or_name(holding_bitcoin_main.coin.coin_name)
      end

      it "returns nil for a non-existent coin" do
        assert_nil Coin.find_by_symbol_or_name("non_existent")
      end
    end
  end

  context "validations" do
    let(:valid_attributes) do
      {
        coin_name: coins(:bitcoin).coin_name,
        symbol: coins(:bitcoin).symbol,
        coingecko_id: coins(:bitcoin).coingecko_id
      }
    end

    it "validates presence and uniqueness of coin_name" do
      invalid_coin = Coin.new(valid_attributes.except(:coin_name))
      refute invalid_coin.valid?
      assert_includes invalid_coin.errors[:coin_name], "can't be blank"
    end

    it "validates presence and uniqueness of symbol" do
      invalid_coin = Coin.new(valid_attributes.except(:symbol))
      refute invalid_coin.valid?
      assert_includes invalid_coin.errors[:symbol], "can't be blank"
    end

    it "validates presence and uniqueness of coingecko_id" do
      invalid_coin = Coin.new(valid_attributes.except(:coingecko_id))
      refute invalid_coin.valid?
      assert_includes invalid_coin.errors[:coingecko_id], "can't be blank"
    end
  end
end